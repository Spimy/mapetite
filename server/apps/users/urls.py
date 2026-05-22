from django.urls import path, re_path, reverse_lazy
from django.contrib.auth import views as auth_views
from . import views
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
    TokenVerifyView,
)
from dj_rest_auth.registration.views import (
    RegisterView,
    ResendEmailVerificationView,
    VerifyEmailView,
)

app_name = "users"

# URL patterns for the users app
urlpatterns = [
    # --- Dashboard authentication URLs ---
    path("sign-in/", views.SignInView.as_view(), name="sign_in"),
    path("sign-out/", views.SignOutView.as_view(), name="sign_out"),

    # --- Password reset URLs ---
    path(
        "reset-password/",
        views.PasswordResetView.as_view(),
        name="password_reset",
    ),
    path(
        "reset-password/sent/",
        views.PasswordResetDoneView.as_view(),
        name="password_reset_done",
    ),
    path(
        "reset-password/<uidb64>/<token>/",
        auth_views.PasswordResetConfirmView.as_view(
            success_url=reverse_lazy("users:password_reset_complete"),
            template_name="users/password_reset/password_reset_confirm.html",
        ),
        name="password_reset_confirm",
    ),
    path(
        "reset-password/complete/",
        auth_views.PasswordResetCompleteView.as_view(
            template_name="users/password_reset/password_reset_complete.html"
        ),
        name="password_reset_complete",
    ),

    # --- Email confirmation URLs ---
    re_path(
        r"^account-confirm-email/(?P<key>[-:\w]+)/$",
        views.ConfirmEmailView.as_view(),
        name="account_confirm_email",
    ),

    # --- API authentication URLs ---
    path("api/auth/google/", views.GoogleLoginView.as_view(), name="google_login"),
    path("api/token/", TokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("api/token/refresh/", TokenRefreshView.as_view(), name="token_refresh"),
    path("api/token/verify/", TokenVerifyView.as_view(), name="token_verify"),

    # --- Registration API URLs ---
    path("api/auth/register/", RegisterView.as_view(), name="rest_register"),
    path("api/auth/verify-email/", VerifyEmailView.as_view(), name="rest_verify_email"),
    path(
        "api/auth/resend-email/",
        ResendEmailVerificationView.as_view(),
        name="rest_resend_email",
    ),
    # The dummy route that exists purely so `allauth` doesn't crash. Please don't use this for anything.
    path(
        "api/auth/account-email-verification-sent/",
        views.HiddenDummyVerifyView.as_view(),
        name="account_email_verification_sent",
    ),
]
