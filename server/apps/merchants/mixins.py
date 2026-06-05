from typing import Any, Dict, Protocol, cast
from django.http import Http404, HttpRequest
from django.db.models import Q, QuerySet
from .models import StoreProfile


class ViewWithRequestKwargs(Protocol):
    request: HttpRequest
    kwargs: Dict[str, Any]
    def get_context_data(self, **kwargs: Any) -> Dict[str, Any]: ...
    def get_active_store(self) -> StoreProfile: ...


class StoreContextMixin:
    def get_active_store(self: ViewWithRequestKwargs) -> StoreProfile:
        store_index = int(self.kwargs.get("store_index", 0))
        stores: QuerySet[StoreProfile] = StoreProfile.objects.filter(
            Q(owner=self.request.user) | Q(staff=self.request.user)
        ).distinct().order_by("id")
        try:
            return cast(StoreProfile, stores[store_index])
        except IndexError:
            raise Http404("Invalid merchant access index.")

    def get_context_data(self: ViewWithRequestKwargs, **kwargs: Any) -> Dict[str, Any]:
        context = super().get_context_data(**kwargs)
        context["store"] = self.get_active_store()
        context["current_index"] = self.kwargs.get("store_index", 0)
        return context