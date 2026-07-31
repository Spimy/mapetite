from django.urls import include, path

app_name = "users"

# URL patterns for the users app
urlpatterns = [
    path("api/", include("apps.users.urls_api")),
    path("", include("apps.users.urls_web")),
]
