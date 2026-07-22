"""
URL configuration for config project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/6.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""

from django.contrib import admin
from django.urls import include, path, reverse_lazy
from django.conf import settings
from django.conf.urls.static import static
from django.contrib.admin.views.decorators import staff_member_required
from drf_spectacular.views import (
    SpectacularAPIView,
    SpectacularRedocView,
    SpectacularSwaggerView,
)

# Customise the admin site headers and titles
admin.site.site_header = "Mapetite Admin"
admin.site.site_title = "Mapetite Admin Portal"
admin.site.index_title = "Welcome to the Mapetite Admin Portal"

urlpatterns = [
    path("admin/", admin.site.urls),
    path("", include("apps.core.urls", namespace="core")),
    path("", include("apps.users.urls", namespace="users")),
    path("", include("apps.merchants.urls", namespace="merchants")),
    path("", include("apps.recipes.urls", namespace="recipes")),
    path("", include("apps.budgets.urls", namespace="budgets")),
    path(
        "api/schema/",
        staff_member_required(
            SpectacularAPIView.as_view(), login_url=reverse_lazy("users:sign_in")
        ),
        name="schema",
    ),
    path(
        "api/schema/swagger-ui/",
        staff_member_required(
            SpectacularSwaggerView.as_view(url_name="schema"),
            login_url=reverse_lazy("users:sign_in"),
        ),
        name="swagger-ui",
    ),
    path(
        "api/schema/redoc/",
        staff_member_required(
            SpectacularRedocView.as_view(url_name="schema"),
            login_url=reverse_lazy("users:sign_in"),
        ),
        name="redoc",
    ),
]

if settings.DEBUG:
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
