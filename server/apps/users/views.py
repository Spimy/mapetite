from django.views.generic import FormView
from django.views import View
from django.shortcuts import render
from django.contrib.auth import login, logout
from .forms import SignInForm
from .mixins import SuccessUrlMixin
from django.contrib.auth.mixins import LoginRequiredMixin
from django.views.generic.base import RedirectView
from django.urls import reverse_lazy
from allauth.socialaccount.providers.google.views import GoogleOAuth2Adapter
from dj_rest_auth.registration.views import SocialLoginView
from allauth.account.models import EmailConfirmationHMAC, EmailConfirmation


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


class GoogleLoginView(SocialLoginView):
    """Takes the access token from the frontend provided by Google and uses it to log in the user via Google OAuth2"""

    adapter_class = GoogleOAuth2Adapter


class ConfirmEmailView(View):
    def get(self, request, key, *args, **kwargs):
        confirmation = self.get_confirmation(key)

        if confirmation:
            confirmation.confirm(self.request)
            return render(request, "users/email_verification_success.html")
        else:
            return render(request, "users/email_verification_failed.html")

    def get_confirmation(self, key):
        """Helper method to extract the confirmation object from the key"""
        try:
            return EmailConfirmationHMAC.from_key(key)
        except Exception:
            try:
                return EmailConfirmation.objects.get(key=key.lower())
            except EmailConfirmation.DoesNotExist:
                return None
