import json
from typing import Any
from apps.merchants.paginator import Template404Paginator
from apps.users.mixins import MerchantRequiredMixin
from django.http.response import HttpResponse as HttpResponse
from django.urls import reverse
from django.utils.translation import gettext_lazy as _
from django.views.generic import CreateView, ListView, RedirectView, TemplateView, View, UpdateView
from django.shortcuts import redirect, render
from django.http import Http404, HttpRequest, JsonResponse
from django.db.models import Q
from django.contrib import messages
from django.contrib.auth import get_user_model
from rest_framework.generics import ListAPIView, RetrieveAPIView, get_object_or_404
from rest_framework.permissions import IsAuthenticated
from .models import Promotion, StoreOperatingHour, StoreProfile, StoreItem, ItemCategory
from .forms import ItemCategoryForm, PromotionForm, StoreItemForm
from .serializers import StoreOperatingHourSerializer, StoreProfileSerializer
from .mixins import StoreContextMixin

# Create your views here.
# API views for merchants app
class StoreListAPIView(ListAPIView):
    """Fetches all stores and their grouped operating hours"""

    queryset = StoreProfile.objects.prefetch_related("operating_hours").all()
    serializer_class = StoreProfileSerializer
    permission_classes = [IsAuthenticated]


class StoreAPIView(RetrieveAPIView):
    """Fetches a single store and its grouped operating hours"""

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


# Django views for merchants app
class DashboardRedirectView(MerchantRequiredMixin, RedirectView):
    """Redirects the base /dashboard/ URL to /dashboard/0/"""

    permanent = False

    def get_redirect_url(self, *args, **kwargs):
        return reverse("merchants:dashboard_home", kwargs={"store_index": 0})
    
    def post(self, request: HttpRequest, *args: Any, **kwargs: Any) -> HttpResponse:
        store_index = request.POST.get("store_index")

        current_route = request.POST.get("current_route", "merchants:dashboard_home")
        if store_index is not None and store_index.isdigit():
            return redirect(current_route, store_index=int(store_index))

        return super().post(request, *args, **kwargs)


class DashboardView(MerchantRequiredMixin, TemplateView):
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
        store_index = self.kwargs.get("store_index", 0)
        
        # Pull stores where the user is EITHER the owner OR in the staff list
        # .distinct() prevents duplicates if a user is accidentally both
        stores = StoreProfile.objects.filter(
            Q(owner=self.request.user) | Q(staff=self.request.user)
        ).distinct().order_by("id")
        
        try:
            active_store = stores[store_index]
        except IndexError:
            raise Http404("Invalid merchant access index portfolio scale.")

        context.update({
            "store": active_store,
            "stores": stores,
            "current_index": store_index,
            "total_stores": stores.count(),
            "has_next": (store_index + 1) < stores.count(),
            "has_prev": store_index > 0
        })
        return context
    

class DashboardItemsView(MerchantRequiredMixin, ListView):
    template_name = "merchants/pages/items-dashboard.html"
    model = StoreItem
    context_object_name = "items"
    paginator_class = Template404Paginator
    paginate_by = 6
    
    def get_queryset(self):
        store_index = self.kwargs.get("store_index", 0)
        stores = StoreProfile.objects.filter(
            Q(owner=self.request.user) | Q(staff=self.request.user)
        ).distinct().order_by("id")
        
        try:
            active_store = stores[store_index]
        except IndexError:
            raise Http404("Invalid merchant access index portfolio scale.")
        
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
        store_index = self.kwargs.get("store_index", 0)
        stores = StoreProfile.objects.filter(
            Q(owner=self.request.user) | Q(staff=self.request.user)
        ).distinct().order_by("id")
        
        try:
            active_store = stores[store_index]
        except IndexError:
            raise Http404("Invalid merchant access index portfolio scale.")
       
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
            "store": active_store,
            "categories": ItemCategory.objects.filter(store=active_store).order_by("display_order", "name"),
            "stores": stores,
            "current_index": store_index,
            "total_stores": stores.count(),
            "has_next": (store_index + 1) < stores.count(),
            "has_prev": store_index > 0,
            "item_form": StoreItemForm(),
            "category_form": ItemCategoryForm(),
            "selected_category": category_param,
            "page_range": page_range,
            "current_search": current_search,
            "edit_item_form": StoreItemForm(auto_id="edit_%s"),
        })
        return context
    
    def post(self, request, *args, **kwargs):
        # A POST request on a ListView requires the object_list to be populated 
        # before rendering a response with form errors.
        self.object_list = self.get_queryset()

        # User submitted the Category Form
        if 'submit_category' in request.POST:
            category_form = ItemCategoryForm(request.POST)
            if category_form.is_valid():
                # Save the category (ensure you link it to the store instance here if needed)
                category = category_form.save(commit=False)
                category.store = get_object_or_404(
                    StoreProfile,
                    id=request.POST.get("current_store"),
                )
                category.save()
                
                # Always redirect after a successful POST
                return redirect('merchants:dashboard_items', store_index=kwargs.get("store_index", 0)) 
            else:
                # Form failed validation. Render the page with the errors in category_form.
                return self.render_to_response(self.get_context_data(category_form=category_form))
            
        # User submitted the Manage Categories Form (bulk update/delete)
        elif 'submit_manage_categories' in request.POST:
            active_store = get_object_or_404(StoreProfile, id=request.POST.get("current_store"))
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

            return redirect('merchants:dashboard_items', store_index=kwargs.get("store_index", 0))

        # User submitted the Item Form
        elif 'submit_item' in request.POST:
            item_form = StoreItemForm(request.POST, request.FILES)
            if item_form.is_valid():
                item = item_form.save(commit=False)
                item.store = get_object_or_404(
                    StoreProfile,
                    id=request.POST.get("current_store"),
                )
                item.save()
                
                return redirect('merchants:dashboard_items', store_index=kwargs.get("store_index", 0))
            else:
                return self.render_to_response(self.get_context_data(item_form=item_form))
            
        elif 'toggle_item' in request.POST:
            active_store = get_object_or_404(StoreProfile, id=request.POST.get("current_store", kwargs.get("store_index", 0)))
            item_id = request.POST.get('toggle_item')
            
            item = get_object_or_404(StoreItem, id=item_id, store=active_store)
            item.is_active = not item.is_active
            item.save(update_fields=['is_active'])
            
            return redirect('merchants:dashboard_items', store_index=kwargs.get("store_index", 0))

        # Fallback if neither button was detected
        return self.get(request, *args, **kwargs)


class DashboardItemUpdateView(MerchantRequiredMixin, UpdateView):
    model = StoreItem
    form_class = StoreItemForm
    template_name = "merchants/pages/items-edit-dashboard.html"

    def get_queryset(self):
        store_index = self.kwargs.get("store_index", 0)
        stores = StoreProfile.objects.filter(
            Q(owner=self.request.user) | Q(staff=self.request.user)
        ).distinct().order_by("id")
        
        try:
            active_store = stores[store_index]
        except IndexError:
            raise Http404("Invalid merchant access index.")
            
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
        store_index = self.kwargs.get("store_index", 0)
        stores = StoreProfile.objects.filter(
            Q(owner=self.request.user) | Q(staff=self.request.user)
        ).distinct().order_by("id")

        context.update({
            "store": stores[store_index],
            "stores": stores,
            "current_index": store_index,
            "total_stores": stores.count(),
            "has_next": (store_index + 1) < stores.count(),
            "has_prev": store_index > 0,
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


class PromotionCreateView(MerchantRequiredMixin, StoreContextMixin, CreateView):
    model = Promotion
    form_class = PromotionForm
    template_name = 'merchants/pages/promotion-create-edit-dashboard.html'

    def get_form_kwargs(self):
        kwargs = super().get_form_kwargs()
        kwargs['store'] = self.get_active_store()
        return kwargs

    def form_valid(self, form):
        form.instance.store = self.get_active_store()
        return super().form_valid(form)

    def get_success_url(self):
        return reverse('merchants:dashboard_promotions', kwargs={'store_index': self.kwargs.get("store_index", 0)})


class PromotionUpdateView(MerchantRequiredMixin, StoreContextMixin, UpdateView):
    model = Promotion
    form_class = PromotionForm
    template_name = 'merchants/pages/promotion-create-edit-dashboard.html'

    def get_queryset(self):
        # Ensure can only edit promos for the active store
        return Promotion.objects.filter(store=self.get_active_store())

    def get_form_kwargs(self):
        kwargs = super().get_form_kwargs()
        kwargs['store'] = self.get_active_store()
        return kwargs

    def get_success_url(self):
        return reverse('merchants:dashboard_promotions', kwargs={'store_index': self.kwargs.get("store_index", 0)})


class PromotionToggleActiveView(MerchantRequiredMixin, StoreContextMixin, View):
    def post(self, request, store_index, pk):
        promotion = get_object_or_404(Promotion, pk=pk, store=self.get_active_store())
        
        if promotion.is_active:
            promotion.is_active = False
            promotion.save()
            messages.success(request, f"'{promotion.title}' has been paused.")
        else:
            if promotion.can_reactivate:
                promotion.is_active = True
                promotion.save()
                messages.success(request, f"'{promotion.title}' is now active again.")
            else:
                messages.error(request, "Cannot reactivate an expired promotion.")
                
        return redirect('merchants:dashboard_promotions', store_index=store_index)


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