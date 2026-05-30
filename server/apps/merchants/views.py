import json
from django.urls import reverse
from django.views.generic import RedirectView, TemplateView, View
from django.shortcuts import redirect, render
from django.http import Http404, JsonResponse
from django.db.models import Q
from apps.users.mixins import MerchantRequiredMixin
from .models import StoreOperatingHour, StoreProfile
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


class DashboardView(MerchantRequiredMixin, TemplateView):
    template_name = "merchants/dashboard.html"

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
            "current_index": store_index,
            "total_stores": stores.count(),
            "has_next": (store_index + 1) < stores.count(),
            "has_prev": store_index > 0
        })
        return context

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