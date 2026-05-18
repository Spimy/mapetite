from django.views.generic import FormView
from django.contrib.auth import login, logout
from .forms import SignInForm
from .mixins import SuccessUrlMixin
from django.contrib.auth.mixins import LoginRequiredMixin
from django.views.generic.base import RedirectView
from django.urls import reverse_lazy


# Create your views here.
class SignInView(SuccessUrlMixin, FormView):
    template_name = "users/signin.html"
    form_class = SignInForm
    success_url = "/admin/"  # TODO: This should be linked to the merchant dashboard once it's implemented

    def form_valid(self, form):
        login(self.request, form.get_user())
        return super().form_valid(form)


class SignOutView(LoginRequiredMixin, RedirectView):
    url = reverse_lazy("users:sign_in")  # TODO: To update to marketing/landing page
    redirect_field_name = None

    def get(self, request, *args, **kwargs):
        logout(request)
        return super(SignOutView, self).get(request, *args, **kwargs)
