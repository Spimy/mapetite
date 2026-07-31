from django.urls import path
from rest_framework_simplejwt.views import (
    TokenBlacklistView,
    TokenBlacklistView,
    TokenObtainPairView,
    TokenRefreshView,
    TokenVerifyView,
)
from dj_rest_auth.registration.views import (
    RegisterView,
    ResendEmailVerificationView,
    VerifyEmailView,
)
from . import views_api

urlpatterns = [
    # --- API authentication URLs ---
    path("auth/google/", views_api.GoogleLoginView.as_view(), name="google_login"),
    path("token/", TokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("token/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
    path("token/verify/", TokenVerifyView.as_view(), name="token_verify"),
    path("token/blacklist/", TokenBlacklistView.as_view(), name="token_blacklist"),
    path("me/", views_api.UserDetailView.as_view(), name="user_detail"),
    # --- Registration API URLs ---
    path("auth/register/", RegisterView.as_view(), name="rest_register"),
    path("auth/verify-email/", VerifyEmailView.as_view(), name="rest_verify_email"),
    path(
        "auth/resend-email/",
        ResendEmailVerificationView.as_view(),
        name="rest_resend_email",
    ),
    # The dummy route that exists purely so `allauth` doesn't crash. Please don't use this for anything.
    path(
        "auth/account-email-verification-sent/",
        views_api.HiddenDummyVerifyView.as_view(),
        name="account_email_verification_sent",
    ),
]
