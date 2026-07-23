from django.urls import path, re_path, reverse_lazy
from django.contrib.auth import views as auth_views
from . import views

app_name = "core"

# URL patterns for the core app
urlpatterns = [
    path(
        "api/notifications/",
        views.NotificationListAPIView.as_view(),
        name="notification_list",
    ),
    path(
        "api/notifications/<int:pk>/",
        views.NotificationDetailAPIView.as_view(),
        name="notification_detail",
    ),
]
