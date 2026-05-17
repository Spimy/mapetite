from django.views.generic.base import View


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
