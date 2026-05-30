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
        "dashboard/<int:store_index>/", views.DashboardView.as_view(), name="dashboard"
    ),
    path("onboarding/", views.OnboardingView.as_view(), name="onboarding"),
    path("store/<int:store_id>/mark-location/", views.MarkLocationView.as_view(), name="mark_location"),
]
