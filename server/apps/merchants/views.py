from rest_framework import generics
from .models import StoreProfile
from .serializers import StoreProfileSerializer
from rest_framework.permissions import IsAuthenticated


# Create your views here.
class StoreListAPIView(generics.ListAPIView):
    """Fetches all stores and their grouped operating hours"""

    queryset = StoreProfile.objects.prefetch_related("operating_hours").all()
    serializer_class = StoreProfileSerializer
    permission_classes = [IsAuthenticated]
