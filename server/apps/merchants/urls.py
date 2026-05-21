from django.urls import path
from . import views

app_name = "merchants"

urlpatterns = [
    path("api/stores/", view=views.StoreListAPIView.as_view(), name="store_list"),
    path("api/stores/<int:store_id>/", view=views.StoreAPIView.as_view(), name="store"),
    path(
        "api/stores/<int:store_id>/operating-hours/",
        view=views.StoreOperatingHoursAPIView.as_view(),
        name="store_operating_hours",
    ),
]
