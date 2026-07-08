import json
from typing import Any, cast
from apps.merchants.paginator import Template404Paginator
from apps.users.models import User
from apps.users.forms import InviteStaffForm, StoreProfileForm, UserInfoForm
from apps.users.mixins import MerchantRequiredMixin
from config.settings import WGS84_SRID, DEFAULT_RADIUS_KM
from django.contrib.auth.forms import PasswordChangeForm
from django.urls import reverse
from django.utils.translation import gettext_lazy as _
from django.views.generic import ListView, RedirectView, TemplateView, View, UpdateView
from django.shortcuts import redirect, render
from django.http import Http404, HttpRequest, JsonResponse
from django.db.models import Q
from django.contrib import messages
from django.contrib.auth import get_user_model
from django.core.mail import send_mail
from django.utils import timezone
from django.contrib.gis.geos import Point
from django.contrib.gis.db.models.functions import Distance
from django.contrib.gis.measure import D
from rest_framework.generics import ListAPIView, RetrieveAPIView, get_object_or_404
from rest_framework.permissions import IsAuthenticated
from rest_framework.exceptions import ValidationError
from rest_framework.response import Response
from .models import Promotion, StoreInvitation, StoreOperatingHour, StoreProfile, StoreItem, ItemCategory
from .forms import ItemCategoryForm, PromotionForm, StoreItemForm
from .serializers import StoreItemSerializer, StoreOperatingHourSerializer, StoreProfileSerializer, NearbyStoreSerializer, NearbyStoresResponseSerializer
from .mixins import StoreContextMixin


# Create your views here.
# API views for merchants app
class StoreListAPIView(ListAPIView):
    """Fetches all stores, optionally filtered by ?type=RESTAURANT or ?type=GROCERY"""

    queryset = StoreProfile.objects.prefetch_related("operating_hours").all()
    serializer_class = StoreProfileSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        merchant_type = self.request.GET.get("type")
        if merchant_type:
            return super().get_queryset().filter(merchant_type=merchant_type.upper())
        return super().get_queryset()

class NearbyStoresListAPIView(ListAPIView):
    """Fetches stores within a certain radius of a given lat/lng point and filtered by ?type=RESTAURANT or ?type=GROCERY"""

    queryset = StoreProfile.objects.prefetch_related("operating_hours").all()
    serializer_class = NearbyStoresResponseSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        lat = self.request.GET.get('lat')
        lng = self.request.GET.get('lng')
        radius_km = self.request.GET.get('radius', DEFAULT_RADIUS_KM)
        merchant_type = self.request.GET.get("type")

        if not lat or not lng:
            raise ValidationError("Please provide 'lat' and 'lng' query parameters.")
        
        if not radius_km or (radius_km is str and not radius_km.isdigit()):
            raise ValidationError("Please provide a valid 'radius' query parameter in kilometers.")

        try:
            user_location = Point(float(lng), float(lat), srid=WGS84_SRID)
            
            if merchant_type:
                return super().get_queryset().filter(
                    location__distance_lte=(user_location, D(km=float(radius_km))),
                    merchant_type=merchant_type.upper()
                ).annotate(
                    distance=Distance('location', user_location)
                ).order_by('distance')
            
            return super().get_queryset().filter(
                location__distance_lte=(user_location, D(km=float(radius_km)))
            ).annotate(
                distance=Distance('location', user_location)
            ).order_by('distance')
            
        except ValueError:
            raise ValidationError("Invalid coordinates provided.")

    def list(self, request, *args, **kwargs):
        # Queryset is already filtered and annotated in get_queryset()
        queryset = self.get_queryset()
        serializer = NearbyStoreSerializer(queryset, many=True)
        
        lat = request.query_params.get('lat')
        lng = request.query_params.get('lng')
        radius_km = request.query_params.get('radius', DEFAULT_RADIUS_KM)

        return Response({
            "search_point": {"lat": float(lat), "lng": float(lng)},
            "radius_km": float(radius_km),
            "count": queryset.count(),
            "results": serializer.data
        })


# TODO: Recommendation system for nearby stores based on user preferences and dietary restrictions while considering the store's operating hours and current status (open/closed).


class StoreAPIView(RetrieveAPIView):
    """Fetches a single store with its operating hours and items"""

    queryset = StoreProfile.objects.prefetch_related("operating_hours").all()
    serializer_class = StoreProfileSerializer
    permission_classes = [IsAuthenticated]
    lookup_field = "id"
    lookup_url_kwarg = "store_id"


class StoreOperatingHoursAPIView(ListAPIView):
    """Fetches and pads the operating hours for a specific store"""

    queryset = StoreOperatingHour.objects.all()
    serializer_class = StoreOperatingHourSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        store_id = self.kwargs.get("store_id")
        get_object_or_404(StoreProfile, id=store_id)
        return super().get_queryset().filter(store_id=store_id).order_by("day_of_week")
    
    
class StoreItemsAPIView(ListAPIView):
    """Fetches all items for a specific store"""

    queryset = StoreItem.objects.select_related("category").filter(is_active=True).all()
    serializer_class = StoreItemSerializer  # You might want to create a dedicated serializer for items
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        store_id = self.kwargs.get("store_id")
        get_object_or_404(StoreProfile, id=store_id)
        # Order by category display order, then category name, then item name for consistent listing
        return super().get_queryset().filter(store_id=store_id).order_by("category__display_order", "category__name", "name")


# Django views for merchants app
class DashboardRedirectView(MerchantRequiredMixin, RedirectView):
    """Redirects the base /dashboard/ URL to /dashboard/0/"""

    permanent = False

    def get_redirect_url(self, *args, **kwargs):
        return reverse("merchants:dashboard_home", kwargs={"store_index": 0})
    
    def post(self, request: HttpRequest, *args: Any, **kwargs: Any):
        store_index = request.POST.get("store_index")

        current_route = request.POST.get("current_route", "merchants:dashboard_home")
        if store_index is not None and store_index.isdigit():
            return redirect(current_route, store_index=int(store_index))

        return super().post(request, *args, **kwargs)


class DashboardView(MerchantRequiredMixin, StoreContextMixin, TemplateView):
    template_name = "merchants/pages/main-dashboard.html"

    def get(self, request, *args, **kwargs):
        has_store = StoreProfile.objects.filter(
            Q(owner=request.user) | Q(staff=request.user)
        ).exists()
        
        if not has_store:
            return redirect("merchants:onboarding")

        return super().get(request, *args, **kwargs)

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context.update({
            "total_stores": context['stores'].count(),
            "has_next": (context['current_index'] + 1) < context['stores'].count(),
            "has_prev": context['current_index'] > 0,
        })
        return context
    

class DashboardItemsView(MerchantRequiredMixin, StoreContextMixin, ListView):
    template_name = "merchants/pages/items-dashboard.html"
    model = StoreItem
    context_object_name = "items"
    paginator_class = Template404Paginator
    paginate_by = 6
    
    def get_queryset(self):
        active_store = self.get_active_store()
        
        queryset = StoreItem.objects.filter(store=active_store).select_related("category").order_by("category__display_order", "category__name", "name")
        
        search_param = self.request.GET.get('search')
        category_param = self.request.GET.get('category')
        
        # Search is global and overrides specific category selections
        if search_param:
            queryset = queryset.filter(
                Q(name__icontains=search_param) | Q(description__icontains=search_param)
            )
        elif category_param:
            queryset = queryset.filter(category__name=category_param)
        
        return queryset
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        active_store = context['store']
       
        page_obj = context.get('page_obj')
        paginator = context.get('paginator')
        page_range = []
        
        if page_obj and paginator:
            current_page = page_obj.number
            total_pages = paginator.num_pages
            
            # Start 1 page before current, but don't go below 1
            start_page = max(current_page - 1, 1)
            # End 2 pages after start
            end_page = start_page + 2
            
            # If the end_page overshoots the total, shift the window back
            if end_page > total_pages:
                end_page = total_pages
                start_page = max(end_page - 2, 1)
                
            page_range = range(start_page, end_page + 1)
       
        category_param = self.request.GET.get('category')
        current_search = self.request.GET.get('search', '') or ''
        
        context.update({
            "categories": ItemCategory.objects.filter(store=active_store).order_by("display_order", "name"),
            "total_stores": context['stores'].count(),
            "has_next": (context['current_index'] + 1) < context['stores'].count(),
            "has_prev": context['current_index'] > 0,
            "item_form": StoreItemForm(store=active_store),
            "category_form": ItemCategoryForm(),
            "selected_category": category_param,
            "page_range": page_range,
            "current_search": current_search,
            "edit_item_form": StoreItemForm(store=active_store, auto_id="edit_%s"),
        })
        return context
    
    def post(self, request, *args, **kwargs):
        # A POST request on a ListView requires the object_list to be populated 
        # before rendering a response with form errors.
        self.object_list = self.get_queryset()
        active_store = self.get_active_store()
        store_index = kwargs.get("store_index", 0)

        # User submitted the Category Form
        if 'submit_category' in request.POST:
            category_form = ItemCategoryForm(request.POST)
            if category_form.is_valid():
                # Save the category (ensure you link it to the store instance here if needed)
                category = category_form.save(commit=False)
                category.store = active_store
                category.save()
                
                # Always redirect after a successful POST
                return redirect('merchants:dashboard_items', store_index=store_index) 
            else:
                # Form failed validation. Render the page with the errors in category_form.
                return self.render_to_response(self.get_context_data(category_form=category_form))
            
        # User submitted the Manage Categories Form (bulk update/delete)
        elif 'submit_manage_categories' in request.POST:
            store_categories = ItemCategory.objects.filter(store=active_store)
            
            categories_to_update = []
            categories_to_delete_ids = []

            for category in store_categories:
                # Check if marked for deletion
                delete_flag = request.POST.get(f"delete_{category.pk}")
                if delete_flag == "true":
                    categories_to_delete_ids.append(category.pk)
                    continue # Skip updating if we are deleting it

                # If not deleted, check for name and order updates
                new_name = request.POST.get(f"name_{category.pk}")
                new_order = request.POST.get(f"order_{category.pk}")
                
                needs_update = False

                if new_name and new_name.strip() != category.name:
                    category.name = new_name.strip()
                    needs_update = True
                    
                if new_order and new_order.isdigit() and int(new_order) != category.display_order:
                    category.display_order = int(new_order)
                    needs_update = True
                    
                if needs_update:
                    categories_to_update.append(category)

            # Perform efficient bulk operations
            if categories_to_delete_ids:
                ItemCategory.objects.filter(id__in=categories_to_delete_ids).delete()
                
            if categories_to_update:
                ItemCategory.objects.bulk_update(categories_to_update, ['name', 'display_order'])

            return redirect('merchants:dashboard_items', store_index=store_index)

        # User submitted the Item Form
        elif 'submit_item' in request.POST:
            item_form = StoreItemForm(request.POST, request.FILES)
            if item_form.is_valid():
                item = item_form.save(commit=False)
                item.store = active_store
                item.save()
                
                return redirect('merchants:dashboard_items', store_index=store_index)
            else:
                return self.render_to_response(self.get_context_data(item_form=item_form))
            
        elif 'toggle_item' in request.POST:
            item_id = request.POST.get('toggle_item')
            
            item = get_object_or_404(StoreItem, id=item_id, store=active_store)
            item.is_active = not item.is_active
            item.save(update_fields=['is_active'])
            
            return redirect('merchants:dashboard_items', store_index=store_index)

        # Fallback if neither button was detected
        return self.get(request, *args, **kwargs)


class DashboardItemUpdateView(MerchantRequiredMixin, StoreContextMixin, UpdateView):
    model = StoreItem
    form_class = StoreItemForm
    template_name = "merchants/pages/items-edit-dashboard.html"

    def get_queryset(self):
        active_store = self.get_active_store()
        return super().get_queryset().filter(store=active_store)
    
    def get(self, request, *args, **kwargs):
        try:
            self.object = self.get_object()
        except Http404:
            self.object = None
            return self.render_to_response(self.get_context_data(item_not_found=True))
        return super().get(request, *args, **kwargs)
    
    def post(self, request, *args, **kwargs):
        try:
            self.object = self.get_object()
        except Http404:
            self.object = None
            return self.render_to_response(self.get_context_data(item_not_found=True))
        return super().post(request, *args, **kwargs)

    def get_success_url(self):
        return reverse('merchants:dashboard_items', kwargs={'store_index': self.kwargs.get("store_index", 0)})
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context.update({
            "total_stores": context['stores'].count(),
            "has_next": (context['current_index'] + 1) < context['stores'].count(),
            "has_prev": context['current_index'] > 0,
        })
        
        return context


class DashboardPromotionListView(MerchantRequiredMixin, StoreContextMixin, ListView):
    template_name = "merchants/pages/promotions-dashboard.html"
    model = Promotion
    context_object_name = "promotions"

    def get_queryset(self):
        return Promotion.objects.filter(store=self.get_active_store()).order_by('-created_at')

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        # Inject the blank create form for the Popover
        context['create_form'] = PromotionForm(store=self.get_active_store())
        context['edit_form'] = PromotionForm(store=self.get_active_store(), auto_id="edit_%s")
        return context
    
    def post(self, request, *args, **kwargs):
        self.object_list = self.get_queryset()
        active_store = self.get_active_store()
        store_index = kwargs.get("store_index", 0)

        # User submitted the CREATE Promotion Form
        if 'submit_promo' in request.POST:
            create_form = PromotionForm(request.POST)
            if create_form.is_valid():
                promo = create_form.save(commit=False)
                promo.store = active_store
                promo.save()
                create_form.save_m2m()
                return redirect('merchants:dashboard_promotions', store_index=store_index)
            else:
                return self.render_to_response(self.get_context_data(create_form=create_form))

        # User submitted the EDIT Promotion Form
        elif 'submit_edit_promo' in request.POST:
            promo_id = request.POST.get("edit_promo_id")
            promo = get_object_or_404(Promotion, id=promo_id, store=active_store)
            
            edit_form = PromotionForm(request.POST, instance=promo, auto_id="edit_%s")
            if edit_form.is_valid():
                edit_form.save() # Saves instance and M2M automatically
                return redirect('merchants:dashboard_promotions', store_index=store_index)
            else:
                # To keep the popover open on error, you'll likely need a snippet of JS 
                # or just render the errors in the HTML.
                return self.render_to_response(self.get_context_data(edit_form=edit_form))

        # User toggled a Promotion (Pause / Reactivate)
        elif 'toggle_promo' in request.POST:
            promo_id = request.POST.get('toggle_promo')
            promo = get_object_or_404(Promotion, id=promo_id, store=active_store)
            
            promo.is_active = not promo.is_active
            promo.save(update_fields=['is_active'])
            return redirect('merchants:dashboard_promotions', store_index=store_index)

        # Fallback
        return self.get(request, *args, **kwargs)


class DashboardPromotionUpdateView(MerchantRequiredMixin, StoreContextMixin, UpdateView):
    model = Promotion
    form_class = PromotionForm
    template_name = 'merchants/pages/promotion-edit-dashboard.html'

    def get_queryset(self):
        # Ensure can only edit promos for the active store
        return Promotion.objects.filter(store=self.get_active_store())

    def get_form_kwargs(self):
        kwargs = super().get_form_kwargs()
        kwargs['store'] = self.get_active_store()
        return kwargs

    def get_success_url(self):
        return reverse('merchants:dashboard_promotions', kwargs={'store_index': self.kwargs.get("store_index", 0)})


class DashboardLocationsAndHoursView(MerchantRequiredMixin, StoreContextMixin, TemplateView):
    template_name = "merchants/pages/location-hours-dashboard.html"
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        
        store = context.get('store') or self.get_active_store()
        if 'store_form' not in context:
            context['store_form'] = StoreProfileForm(instance=store)
            
        existing_hours = {h.day_of_week: h for h in StoreOperatingHour.objects.filter(store=store)}
        
        days_info = []
        day_names = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']
        day_labels = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
        
        for i in range(7):
            hour_obj = existing_hours.get(i) # Look up the day in the DB results
            
            days_info.append({
                'name': day_names[i],       # "monday" (for the HTML name attribute)
                'label': day_labels[i],     # "Monday" (for the visual label)
                'is_active': bool(hour_obj), # True if row exists, False if closed
                'open_time': hour_obj.open_time.strftime('%H:%M') if hour_obj else '',
                'close_time': hour_obj.close_time.strftime('%H:%M') if hour_obj else '',
            })
            
        context['days_info'] = days_info
        
        return context

    def post(self, request, *args, **kwargs):
        context = self.get_context_data(**kwargs)
        store = context.get('store') or self.get_active_store()
        
        if 'submit_store_info' in request.POST:
            form = StoreProfileForm(request.POST, instance=store)
            
            if form.is_valid():
                form.save()
                messages.success(request, "Store location and details updated successfully!")
                return redirect('merchants:dashboard_locations_and_hours', store_index=kwargs.get('store_index'))
            
            else:
                messages.error(request, "There was an error updating your store. Please check below.")
                return self.render_to_response(self.get_context_data(store_form=form))
            
        elif 'submit_operating_hours' in request.POST:
            days_mapping = {
                'monday': 0, 'tuesday': 1, 'wednesday': 2, 
                'thursday': 3, 'friday': 4, 'saturday': 5, 'sunday': 6
            }

            try:
                for day_name, day_int in days_mapping.items():
                    is_active = f"{day_name}_active" in request.POST

                    if is_active:
                        open_time = request.POST.get(f"{day_name}_open")
                        close_time = request.POST.get(f"{day_name}_close")

                        if open_time and close_time:
                            StoreOperatingHour.objects.update_or_create(
                                store=store,
                                day_of_week=day_int,
                                defaults={
                                    'open_time': open_time,
                                    'close_time': close_time
                                }
                            )
                    else:
                        StoreOperatingHour.objects.filter(store=store, day_of_week=day_int).delete()

                messages.success(request, "Operating hours updated successfully!")
                
            except Exception as e:
                messages.error(request, f"Error saving hours. Please ensure times are valid.")

            return redirect('merchants:dashboard_locations_and_hours', store_index=kwargs.get('store_index'))

        return self.render_to_response(self.get_context_data())


class DashboardStaffView(MerchantRequiredMixin, StoreContextMixin, ListView):
    template_name = "merchants/pages/staff-dashboard.html"
    model = get_user_model()
    context_object_name = "staff_members"
    
    def get_queryset(self):
        return self.get_active_store().staff.all()
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        store = self.get_active_store()
        context['pending_invites'] = StoreInvitation.objects.filter(store=store)
        context['invite_form'] = InviteStaffForm()
        return context
    
    def get(self, request, *args, **kwargs):
        store = self.get_active_store()
        if request.user != store.owner:
            messages.error(request, "Only the store owner can manage staff.")
            return redirect('merchants:dashboard_home', store_index=kwargs.get("store_index", 0))
        return super().get(request, *args, **kwargs)


    def post(self, request, *args, **kwargs):
        store = self.get_active_store()
        action = request.POST.get('action')

        # Security check: Only the owner should perform these destructive actions
        is_owner = request.user == store.owner

        if action == "invite_staff" and is_owner:
            owner = cast(User, request.user)
            form = InviteStaffForm(request.POST)
            
            if form.is_valid():
                email = form.cleaned_data['email']
                
                if store.staff.filter(email=email).exists() or owner.email == email:
                    messages.error(request, "This user is already part of the store.")
                else:
                    invite = form.save(commit=False)
                    invite.store = store
                    invite.save()
                    
                    self.send_invitation_email(request, invite)
                    messages.success(request, f"Invitation sent to {email}.")

        elif action == "remove_staff" and is_owner:
            user_id = request.POST.get('user_id')
            user_to_remove = get_object_or_404(User, id=user_id)
            store.staff.remove(user_to_remove)
            messages.success(request, f"{user_to_remove.email} removed from staff.")

        elif action == "transfer_ownership" and is_owner:
            user_id = request.POST.get('user_id')
            new_owner = get_object_or_404(User, id=user_id)
            
            if new_owner in store.staff.all():
                store.staff.remove(new_owner) # Remove them from staff list
                store.staff.add(request.user) # Add old owner to staff list
                store.owner = new_owner       # Set new owner
                store.save()
                messages.success(request, f"Ownership transferred to {new_owner.email}.")

        elif action == "cancel_invite" and is_owner:
            invite_id = request.POST.get('invite_id')
            StoreInvitation.objects.filter(id=invite_id, store=store).delete()
            messages.success(request, "Invitation canceled.")

        elif action == "resend_invite" and is_owner:
            invite_id = request.POST.get('invite_id')
            invite = get_object_or_404(StoreInvitation, id=invite_id, store=store)
            invite.created_at = timezone.now() # Reset expiration
            invite.save()
            self.send_invitation_email(request, invite)
            messages.success(request, f"Invitation resent to {invite.email}.")

        return redirect('merchants:dashboard_staff', store_index=self.kwargs['store_index'])

    def send_invitation_email(self, request, invite):
        invite_url = request.build_absolute_uri(
            reverse('merchants:accept_invite', kwargs={'token': invite.token})
        )
        send_mail(
            subject=f"Invitation to join {invite.store.business_name}",
            message=f"You've been invited! Click here to accept: {invite_url}",
            from_email=None,
            recipient_list=[invite.email],
        )


class AcceptInviteView(View):
    def get(self, request, token, *args, **kwargs):
        # The token comes from the URL parameters and is used to identify the invitation
        invite = get_object_or_404(StoreInvitation, token=token)

        if invite.is_expired:
            messages.error(request, "This invitation link has expired.")
            return redirect('account_login') # Assuming you use allauth

        user = User.objects.filter(email=invite.email).first()

        if not user:
            # User doesn't exist then Create account
            temp_password = User.objects.make_random_password(length=12)
            
            # Using email for username
            user = User.objects.create_user(
                username=invite.email, 
                email=invite.email,
                password=temp_password,
                first_name=invite.first_name,
                last_name=invite.last_name,
                is_merchant=True, # Automatically mark as merchant since they have a store to manage
            )
            
            # Email them the temp password
            send_mail(
                "Your New Account Details",
                f"An account was created for you. Your temporary password is: {temp_password}\nPlease log in and change it.",
                None,
                [user.email]
            )
            messages.success(request, "Account created! Check your email for your temporary password.")
        else:
            name_updated = False
            
            if not user.first_name and invite.first_name:
                user.first_name = invite.first_name
                name_updated = True
                
            if not user.last_name and invite.last_name:
                user.last_name = invite.last_name
                name_updated = True
                
            if name_updated:
                user.save()
                
            messages.success(request, f"You have been added to {invite.store.business_name} as staff.")

        # Add to store staff & cleanup
        invite.store.staff.add(user)
        invite.delete()
        
        if not user.is_merchant:
            user.is_merchant = True
            user.save(update_fields=['is_merchant'])
        
        return redirect('users:sign_in')


class DashboardSettingsView(MerchantRequiredMixin, StoreContextMixin, TemplateView):
    template_name = "merchants/pages/settings-dashboard.html"

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        user = cast(User, self.request.user)
        
        store = context.get('store')
        context['user_form'] = UserInfoForm(instance=getattr(user, 'user_profile'), store=store)
        
        password_form = PasswordChangeForm(user=user)
        for field in password_form.fields.values():
            field.widget.attrs.pop('autofocus', None)            
        context['password_form'] = password_form
        
        return context

    def post(self, request, *args, **kwargs):
        context = self.get_context_data(**kwargs)
        store = context.get('store')
        
        if 'submit_user_info' in request.POST:
            form = UserInfoForm(
                request.POST, 
                request.FILES, 
                instance=request.user.user_profile, 
                store=store
            )
            
            if form.is_valid():
                form.save()
                messages.success(request, "Settings updated!")
                return redirect('merchants:dashboard_settings', store_index=kwargs.get("store_index", 0))
            
            # If invalid, re-render the context with the errored form
            context['user_form'] = form
            return self.render_to_response(context)

        elif 'submit_password' in request.POST:
            form = PasswordChangeForm(user=request.user, data=request.POST)
            if form.is_valid():
                form.save()
                messages.success(request, "Password changed successfully!")
                return redirect('merchants:dashboard_settings', store_index=kwargs.get("store_index", 0))
            return self.render_to_response(self.get_context_data(password_form=form))

        return self.get(request, *args, **kwargs)


class OnboardingView(MerchantRequiredMixin, TemplateView):
    template_name = "merchants/onboarding.html"
    
    
class MarkLocationView(MerchantRequiredMixin, View):
    """Handles both rendering the Leaflet placement UI and receiving the coordinates."""
    
    def get(self, request, store_id, *args, **kwargs):
        store = get_object_or_404(StoreProfile, id=store_id, owners=request.user)
        return render(request, "merchants/mark_location.html", {"store": store})

    def post(self, request, store_id, *args, **kwargs):
        store = get_object_or_404(StoreProfile, id=store_id, owners=request.user)
        
        # Accept standard decimals regardless of what map framework sent it
        try:
            data = json.loads(request.body)
            lat = data.get("latitude")
            lon = data.get("longitude")
            
            if not lat or not lon:
                return JsonResponse({"error": "Missing location data"}, status=400)
                
            # Internal abstraction layer parses clean coordinates safely into PostGIS POINT
            store.set_coordinates(lat, lon)
            store.save()
            
            return JsonResponse({"status": "success", "redirect_url": reverse("merchants:dashboard_redirect")})
        except (ValueError, json.JSONDecodeError):
            return JsonResponse({"error": "Invalid request data processing layer"}, status=400)