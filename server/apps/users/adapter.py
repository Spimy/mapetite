from allauth.account.adapter import DefaultAccountAdapter, HttpResponseRedirect
from django.urls import reverse
from allauth.utils import build_absolute_uri  # Import the utility function


class AccountAdapter(DefaultAccountAdapter):
    def get_email_confirmation_url(self, request, emailconfirmation):
        """
        Override the default URL builder to use the 'users' namespace.
        """
        url = reverse("users:account_confirm_email",
                      args=[emailconfirmation.key])

        # Use the imported function instead of self.build_absolute_uri
        return build_absolute_uri(request, url)

    def respond_email_verification_sent(self, request, user):
        """
        Override the default redirect to use the 'users' namespace 
        after a registration email is sent.
        """
        url = reverse("users:account_email_verification_sent")
        return HttpResponseRedirect(url)
