import json
from typing import Any
from django.http.response import HttpResponse as HttpResponse
from django.urls import reverse
from django.utils.translation import gettext_lazy as _
from django.views.generic import ListView, RedirectView, TemplateView, View
from django.shortcuts import redirect, render
from django.http import Http404, HttpRequest, JsonResponse
from django.db.models import Q
from apps.users.mixins import MerchantRequiredMixin
from .models import StoreOperatingHour, StoreProfile, StoreItem, ItemCategory
from .forms import ItemCategoryForm, StoreItemForm
from .serializers import StoreOperatingHourSerializer, StoreProfileSerializer
from rest_framework.generics import ListAPIView, RetrieveAPIView, get_object_or_404
from rest_framework.permissions import IsAuthenticated


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
        return reverse("merchants:dashboard", kwargs={"store_index": 0})
    
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
    model = StoreItem  # Changed from ItemCategory
    context_object_name = "items"
    
    def get_queryset(self):
        store_index = self.kwargs.get("store_index", 0)
        stores = StoreProfile.objects.filter(
            Q(owner=self.request.user) | Q(staff=self.request.user)
        ).distinct().order_by("id")
        
        try:
            active_store = stores[store_index]
        except IndexError:
            raise Http404("Invalid merchant access index portfolio scale.")
        
        return StoreItem.objects.filter(store=active_store).select_related("category").order_by("category__display_order", "category__name", "name")
    
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
        
        context.update({
            "store": active_store,
            "categories": ItemCategory.objects.filter(store=active_store).order_by("display_order", "name"),
            "stores": stores,
            "current_index": store_index,
            "total_stores": stores.count(),
            "has_next": (store_index + 1) < stores.count(),
            "has_prev": store_index > 0,
            "item_form": StoreItemForm(),
            "category_form": ItemCategoryForm()
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

        # User submitted the Item Form
        elif 'submit_item' in request.POST:
            item_form = StoreItemForm(request.POST)
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

        # Fallback if neither button was detected
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