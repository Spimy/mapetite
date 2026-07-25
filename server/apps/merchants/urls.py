from django.urls import path
from . import views

app_name = "merchants"

urlpatterns = [
    # --- API URLs ---
    path("api/stores/", view=views.StoreListAPIView.as_view(), name="store_list"),
    path("api/stores/<int:store_id>/", view=views.StoreAPIView.as_view(), name="store"),
    path(
        "api/stores/<int:store_id>/operating-hours/",
        view=views.StoreOperatingHoursAPIView.as_view(),
        name="store_operating_hours",
    ),
    path("api/stores/<int:store_id>/items/", view=views.StoreItemsAPIView.as_view(), name="store_items"),
    path("api/stores/<int:store_id>/promotions/", view=views.StorePromotionsAPIView.as_view(), name="store_promotions"),
    path('api/stores/nearby/', views.NearbyStoresListAPIView.as_view(), name='nearby_stores'),
    path('api/items/<int:item_id>/promotions/', view=views.ItemPromotionsAPIView.as_view(), name='item_promotions'),
    # --- Dashboard URLs ---
    path("dashboard/", view=views.DashboardRedirectView.as_view(), name="dashboard"),
    path(
        "dashboard/<int:store_index>/", views.DashboardView.as_view(), name="dashboard_home"
    ),
    path(
        "dashboard/<int:store_index>/items/", views.DashboardItemsView.as_view(), name="dashboard_items"
    ),
    path(
        "dashboard/<int:store_index>/items/<int:pk>/", views.DashboardItemUpdateView.as_view(), name='dashboard_edit_item'
    ),
    path(
        "dashboard/<int:store_index>/promotions/", views.DashboardPromotionListView.as_view(), name="dashboard_promotions"
    ),
    path('dashboard/<int:store_index>/promotions/<int:pk>/', views.DashboardPromotionUpdateView.as_view(), name='dashboard_promotion_edit'),
    path(
        "dashboard/<int:store_index>/locations-and-hours/", views.DashboardLocationsAndHoursView.as_view(), name="dashboard_locations_and_hours"
    ),
    path(
        "dashboard/<int:store_index>/staff/", views.DashboardStaffView.as_view(), name="dashboard_staff"
    ),
    path("invite/accept/<uuid:token>/", views.AcceptInviteView.as_view(), name="accept_invite"),
    path(
        "dashboard/<int:store_index>/settings/", views.DashboardSettingsView.as_view(), name="dashboard_settings"
    ),
    path("onboarding/", views.OnboardingView.as_view(), name="onboarding"),
    path("onboarding/<int:pk>/", views.OnboardingStoreDetailView.as_view(), name="onboarding_detail"),
    path("onboarding/<int:pk>/claim/", views.ClaimRequestCreateView.as_view(), name="claim_request_create"),
    path("store/<int:store_id>/mark-location/", views.MarkLocationView.as_view(), name="mark_location"),
]
