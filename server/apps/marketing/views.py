from django.urls import reverse_lazy
from django.views.generic import TemplateView, FormView
from django.core.mail import send_mail
from django.contrib import messages
from django.conf import settings
from .forms import ContactForm


# Create your views here.
class LandingPageView(TemplateView):
    template_name = "marketing/pages/landing.html"


class SolutionsPageView(TemplateView):
    template_name = "marketing/pages/solutions.html"


class PricingPageView(TemplateView):
    template_name = "marketing/pages/pricing.html"


class TestimonialsPageView(TemplateView):
    template_name = "marketing/pages/testimonials.html"


class ContactPageView(FormView):
    template_name = "marketing/pages/contact.html"
    form_class = ContactForm
    success_url = reverse_lazy("marketing:contact-page")

    def form_valid(self, form):
        data = form.cleaned_data
        business_name = data.get("business_name")
        business_type = data.get("business_type")
        contact_person = data.get("contact_person")
        phone_number = data.get("phone_number")
        email = data.get("email")
        message = data.get("message", "No message provided.")

        # Format the email subject and body
        subject = f"New Merchant Lead: {business_name} ({business_type.title()})"

        email_body = f"""
        New contact form submission from Mapetite:

        Business Details:
        - Name: {business_name}
        - Type: {business_type.title()}

        Contact Information:
        - Person: {contact_person}
        - Phone: {phone_number}
        - Email: {email}

        Message:
        {message}
        """

        send_mail(
            subject=subject,
            message=email_body,
            from_email=settings.EMAIL_HOST_USER,
            recipient_list=[settings.EMAIL_HOST_USER],
            fail_silently=not settings.DEBUG,
        )

        messages.success(
            self.request,
            "Thanks for reaching out! Our marketing team will get back to you shortly.",
        )

        return super().form_valid(form)
