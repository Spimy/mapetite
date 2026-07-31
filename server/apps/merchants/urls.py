from django.urls import include, path

app_name = "merchants"


urlpatterns = [
    path("api/", include("apps.merchants.urls_api")),
    path("", include("apps.merchants.urls_web")),
]
