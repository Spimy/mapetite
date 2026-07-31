from django.urls import path, re_path
from django.contrib.auth import views as views_auth
from . import views_web

urlpatterns = [
    # --- Dashboard authentication URLs ---
    path("sign-in/", views_web.SignInView.as_view(), name="sign_in"),
    path("sign-out/", views_web.SignOutView.as_view(), name="sign_out"),
    # --- Password reset URLs ---
    path(
        "reset-password/",
        views_web.PasswordResetView.as_view(),
        name="password_reset",
    ),
    path(
        "reset-password/sent/",
        views_web.PasswordResetDoneView.as_view(),
        name="password_reset_done",
    ),
    path(
        "reset-password/<uidb64>/<token>/",
        views_web.PasswordResetConfirmView.as_view(),
        name="password_reset_confirm",
    ),
    path(
        "reset-password/complete/",
        views_auth.PasswordResetCompleteView.as_view(
            template_name="users/password_reset/password_reset_complete.html"
        ),
        name="password_reset_complete",
    ),
    # --- Email confirmation URLs ---
    re_path(
        r"^account-confirm-email/(?P<key>[-:\w]+)/$",
        views_web.ConfirmEmailView.as_view(),
        name="account_confirm_email",
    ),
]
