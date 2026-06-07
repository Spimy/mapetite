from typing import cast
from django.http import HttpRequest
from django.views.generic.base import View
from django.contrib.auth.mixins import UserPassesTestMixin
from django.core.exceptions import PermissionDenied
from .models import User


class SuccessUrlMixin(View):
    """Allows to redirect a view to its correct success url."""

    def get_success_url(self) -> str:
        next_url = self.request.GET.get("next")
        if next_url:
            return next_url

        parent_get = getattr(super(), "get_success_url", None)
        if callable(parent_get):
            parent_result = parent_get()

            if isinstance(parent_result, str):
                return parent_result

            if parent_result is not None:
                return str(parent_result)

        success = getattr(self, "success_url", None)
        if isinstance(success, str):
            return success

        return ""


class MerchantRequiredMixin(UserPassesTestMixin):
    """Mixin to check if the user is a merchant"""

    request: HttpRequest

    def test_func(self):
        user = cast(User, self.request.user)
        return user.is_authenticated and user.is_merchant

    def handle_no_permission(self):
        if not self.request.user.is_authenticated:
            return super().handle_no_permission()

        raise PermissionDenied("You must be a merchant to view this page.")
