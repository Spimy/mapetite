from django.urls import path, re_path, reverse_lazy
from django.contrib.auth import views as auth_views
from . import views

app_name = "budgets"

# URL patterns for the budgets app
urlpatterns = [
    path(
        "api/spending-records/",
        views.SpendingRecordListCreateAPIView.as_view(),
        name="spending_record_list",
    ),
    path(
        "api/spending-records/<int:pk>/",
        views.SpendingRecordDetailAPIView.as_view(),
        name="spending_record_detail",
    ),
]
