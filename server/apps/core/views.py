from rest_framework import generics
from rest_framework.permissions import IsAuthenticated
from drf_spectacular.utils import extend_schema, extend_schema_view
from .models import Notification
from .serializers import NotificationSerializer


@extend_schema_view(
    get=extend_schema(
        summary="List notifications",
        description="Retrieve a list of notifications for the authenticated user.",
    ),
)
class NotificationListAPIView(generics.ListAPIView):
    """
    API view to list all notifications for the authenticated user.
    """

    queryset = Notification.objects.all()
    serializer_class = NotificationSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        """
        Return notifications for the authenticated user, ordered by date created.
        """
        return (
            super()
            .get_queryset()
            .filter(user=self.request.user)
            .order_by("-created_at")
        )


@extend_schema_view(
    get=extend_schema(
        summary="Retrieve a notification",
        description="Retrieve details of a specific notification for the authenticated user.",
    ),
    patch=extend_schema(
        summary="Update notification read status",
        description="Partially update a specific notification. Only the `is_read` status can be modified.",
    ),
)
class NotificationDetailAPIView(generics.RetrieveUpdateAPIView):
    """
    API view to retrieve a specific notification for the authenticated user.
    """

    queryset = Notification.objects.all()
    serializer_class = NotificationSerializer
    permission_classes = [IsAuthenticated]
    http_method_names = ["get", "patch", "head", "options"]

    def get_queryset(self):
        """
        Return notifications for the authenticated user.
        """
        return super().get_queryset().filter(user=self.request.user)
