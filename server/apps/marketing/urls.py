from django.urls import path
from .views import (
    LandingPageView,
    PricingPageView,
    SolutionsPageView,
    TestimonialsPageView,
)

app_name = "marketing"

urlpatterns = [
    path("", LandingPageView.as_view(), name="landing-page"),
    path("solutions/", SolutionsPageView.as_view(), name="solutions-page"),
    path("pricing/", PricingPageView.as_view(), name="pricing-page"),
    path("testimonials/", TestimonialsPageView.as_view(), name="testimonials-page"),
]
