from typing import Any, Dict, cast
from django.http import Http404, HttpRequest
from django.db.models import Q, QuerySet
from django.views.generic.base import ContextMixin
from .models import StoreProfile


class StoreContextMixin(ContextMixin):
    request: HttpRequest
    kwargs: Dict[str, Any]
    
    def get_all_stores(self) -> QuerySet[StoreProfile]:
        return StoreProfile.objects.filter(
            Q(owner=self.request.user) | Q(staff=self.request.user)
        ).distinct().order_by("id")
    
    def get_active_store(self, stores: QuerySet[StoreProfile] | None = None) -> StoreProfile:
        store_index = int(self.kwargs.get("store_index", 0))
        if stores is None:
            stores = self.get_all_stores()
            
        try:
            return cast(StoreProfile, stores[store_index])
        except IndexError:
            raise Http404("Invalid merchant access index.")

    def get_context_data(self, **kwargs: Any) -> Dict[str, Any]:
        context = super().get_context_data(**kwargs)
        stores = self.get_all_stores()
        context["store"] = self.get_active_store(stores)
        context["stores"] = stores
        context["current_index"] = self.kwargs.get("store_index", 0)
        return context
