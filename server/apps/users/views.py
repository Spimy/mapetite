from django.views.generic import FormView
from django.contrib.auth import login
from .forms import SignInForm
from .mixins import SuccessUrlMixin


# Create your views here.
class SignInView(SuccessUrlMixin, FormView):
    template_name = "users/signin.html"
    form_class = SignInForm
    success_url = "/admin/"  # TODO: This should be linked to the merchant dashboard once it's implemented

    def form_valid(self, form):
        login(self.request, form.get_user())
        return super().form_valid(form)
