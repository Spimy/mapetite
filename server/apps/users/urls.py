from django.urls import path
from . import views

app_name = "users"

# URL patterns for the users app
urlpatterns = [
    path("sign-in/", views.SignInView.as_view(), name="sign_in"),
    path("sign-out/", views.SignOutView.as_view(), name="sign_out"),
]
