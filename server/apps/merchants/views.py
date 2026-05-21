from rest_framework import generics
from .models import StoreOperatingHour, StoreProfile
from .serializers import StoreOperatingHourSerializer, StoreProfileSerializer
from rest_framework.permissions import IsAuthenticated


# Create your views here.
class StoreListAPIView(generics.ListAPIView):
    """Fetches all stores and their grouped operating hours"""

    queryset = StoreProfile.objects.prefetch_related("operating_hours").all()
    serializer_class = StoreProfileSerializer
    permission_classes = [IsAuthenticated]


class StoreAPIView(generics.RetrieveAPIView):
    """Fetches a single store and its grouped operating hours"""

    queryset = StoreProfile.objects.prefetch_related("operating_hours").all()
    serializer_class = StoreProfileSerializer
    permission_classes = [IsAuthenticated]
    lookup_field = "id"
    lookup_url_kwarg = "store_id"


class StoreOperatingHoursAPIView(generics.ListAPIView):
    """Fetches only the operating hours for a store"""

    queryset = StoreOperatingHour.objects.all()
    serializer_class = StoreOperatingHourSerializer
    permission_classes = [IsAuthenticated]
    lookup_field = "store_id"
    lookup_url_kwarg = "store_id"
