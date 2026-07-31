from django.urls import path
from . import views_api
from . import views_api_recommendation

urlpatterns = [
    path("stores/", view=views_api.StoreListAPIView.as_view(), name="store_list"),
    path(
        "stores/<int:store_id>/",
        view=views_api.StoreAPIView.as_view(),
        name="store",
    ),
    path(
        "stores/<int:store_id>/operating-hours/",
        view=views_api.StoreOperatingHoursAPIView.as_view(),
        name="store_operating_hours",
    ),
    path(
        "stores/<int:store_id>/items/",
        view=views_api.StoreItemsAPIView.as_view(),
        name="store_items",
    ),
    path(
        "stores/<int:store_id>/promotions/",
        view=views_api.StorePromotionsAPIView.as_view(),
        name="store_promotions",
    ),
    path(
        "stores/nearby/",
        views_api.NearbyStoresListAPIView.as_view(),
        name="nearby_stores",
    ),
    path(
        "items/<int:item_id>/promotions/",
        view=views_api.ItemPromotionsAPIView.as_view(),
        name="item_promotions",
    ),
    path(
        "recommendations/top-pick/",
        views_api_recommendation.RestaurantTopPickAPIView.as_view(),
        name="restaurant_top_pick",
    ),
    path(
        "recommendations/restaurants/",
        views_api_recommendation.RankedRestaurantsAPIView.as_view(),
        name="ranked_restaurants",
    ),
]
