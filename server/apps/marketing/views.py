from django.views.generic import TemplateView


# Create your views here.
class LandingPageView(TemplateView):
    template_name = "marketing/pages/landing.html"


class SolutionsPageView(TemplateView):
    template_name = "marketing/pages/solutions.html"
