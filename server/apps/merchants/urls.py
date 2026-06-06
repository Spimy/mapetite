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
        "dashboard/<int:store_index>/locations-and-hours/", views.DashboardView.as_view(), name="dashboard_locations_and_hours"
    ),
    path(
        "dashboard/<int:store_index>/staff/", views.DashboardStaffView.as_view(), name="dashboard_staff"
    ),
    path(
        "dashboard/<int:store_index>/settings/", views.DashboardView.as_view(), name="dashboard_settings"
    ),
    path("onboarding/", views.OnboardingView.as_view(), name="onboarding"),
    path("store/<int:store_id>/mark-location/", views.MarkLocationView.as_view(), name="mark_location"),
]
