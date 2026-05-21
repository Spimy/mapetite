from django.urls import path
from . import views

app_name = "merchants"

urlpatterns = [
    path("api/stores/", view=views.StoreListAPIView.as_view(), name="store_list"),
]
