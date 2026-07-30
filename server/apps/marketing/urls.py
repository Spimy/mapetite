from django.urls import path
from .views import LandingPageView, PricingPageView, SolutionsPageView

app_name = "marketing"

urlpatterns = [
    path("", LandingPageView.as_view(), name="landing-page"),
    path("solutions/", SolutionsPageView.as_view(), name="solutions-page"),
    path("pricing/", PricingPageView.as_view(), name="pricing-page"),
]
