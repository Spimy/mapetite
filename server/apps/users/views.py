from django.views.generic import FormView
from django.conf import settings
from django.contrib.auth import views as auth_views, login, logout
from django.contrib import messages
from django.utils import timezone
from django.shortcuts import redirect
from django.views import View
from django.shortcuts import render
from .forms import SignInForm
from .mixins import SuccessUrlMixin
from django.contrib.auth.mixins import LoginRequiredMixin
from django.views.generic.base import RedirectView
from django.urls import reverse_lazy
from allauth.socialaccount.providers.google.views import GoogleOAuth2Adapter
from dj_rest_auth.registration.views import SocialLoginView, VerifyEmailView
from allauth.account.models import EmailConfirmationHMAC, EmailConfirmation
from drf_spectacular.utils import extend_schema_view, extend_schema


# Create your views here.
class SignInView(SuccessUrlMixin, FormView):
    template_name = "users/signin.html"
    form_class = SignInForm
    # TODO: This should be linked to the merchant dashboard once it's implemented
    success_url = "/admin/"

    def form_valid(self, form):
        login(self.request, form.get_user())
        return super().form_valid(form)


class SignOutView(LoginRequiredMixin, RedirectView):
    # TODO: To update to marketing/landing page
    url = reverse_lazy("users:sign_in")
    redirect_field_name = None

    def get(self, request, *args, **kwargs):
        logout(request)
        return super(SignOutView, self).get(request, *args, **kwargs)


class PasswordResetView(auth_views.PasswordResetView):
    success_url = reverse_lazy("users:password_reset_done")
    email_template_name = "users/password_reset/password_reset_email.txt"
    template_name = "users/password_reset/password_reset_form.html"

    # Cooldown period in seconds to prevent spamming password reset requests
    cooldown_seconds = 60

    def form_valid(self, form):
        # Check if the user is spamming the request
        last_request_time_str = self.request.session.get("last_password_reset_request")
        if last_request_time_str:
            last_request_time = timezone.datetime.fromisoformat(last_request_time_str)
            time_since_last_request = timezone.now() - last_request_time

            if time_since_last_request.total_seconds() < self.cooldown_seconds:
                remaining_time = int(
                    self.cooldown_seconds - time_since_last_request.total_seconds()
                )
                messages.error(
                    self.request,
                    f"Please wait {remaining_time} seconds before requesting another email.",
                )

                # If they are on the form page, redisplay the form.
                # If they submitted from the 'done' page, redirect back to the 'done' page.
                if self.request.POST.get("from_resend_page"):
                    return redirect("users:password_reset_done")
                return self.form_invalid(form)

        # Record the time of this request in the session
        self.request.session["last_password_reset_request"] = timezone.now().isoformat()

        # Save the submitted email in the session for the next step
        self.request.session["reset_email"] = form.cleaned_data["email"]

        return super().form_valid(form)


class PasswordResetDoneView(auth_views.PasswordResetDoneView):
    template_name = "users/password_reset/password_reset_done.html"

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context["email"] = self.request.session.get("reset_email")
        timeout_seconds = getattr(settings, "PASSWORD_RESET_TIMEOUT", 259200)

        # Convert seconds to hours if it's large, otherwise minutes (for 30 minutes, it's 1800s)
        if timeout_seconds >= 3600:
            timeout_hours = timeout_seconds // 3600
            # If divisible by 24, make it days
            if timeout_hours >= 24 and timeout_hours % 24 == 0:
                timeout_display = f"{timeout_hours // 24} days"
            else:
                timeout_display = f"{timeout_hours} hours"
        else:
            timeout_display = f"{timeout_seconds // 60} minutes"

        context["timeout_display"] = timeout_display
        return context


class GoogleLoginView(SocialLoginView):
    """Takes the access token from the frontend provided by Google and uses it to log in the user via Google OAuth2"""

    adapter_class = GoogleOAuth2Adapter


class ConfirmEmailView(View):
    def get(self, request, key, *args, **kwargs):
        confirmation = self.get_confirmation(key)

        if confirmation:
            confirmation.confirm(self.request)
            return render(
                request, "users/email_verification/email_verification_success.html"
            )
        else:
            return render(
                request, "users/email_verification/email_verification_failed.html"
            )

    def get_confirmation(self, key):
        """Helper method to extract the confirmation object from the key"""
        try:
            return EmailConfirmationHMAC.from_key(key)
        except Exception:
            try:
                return EmailConfirmation.objects.get(key=key.lower())
            except EmailConfirmation.DoesNotExist:
                return None


@extend_schema_view(
    post=extend_schema(
        exclude=True  # This hides the dummy route entirely from Swagger/ReDoc
    )
)
class HiddenDummyVerifyView(VerifyEmailView):
    """
    Used for the allauth dummy route. We hide it so it doesn't clutter the API docs.
    """

    pass
