from rest_framework.permissions import SAFE_METHODS, BasePermission


class IsAuthorOrReadOnly(BasePermission):
    """
    Custom permission to only allow authors to edit their own items. Read-only permissions are allowed for any request.
    Superusers have full access to all items, regardless of authorship.
    """

    def has_object_permission(self, request, view, obj):
        if request.method in SAFE_METHODS:
            return True

        # Write permissions are only allowed to the author of the item or superusers.
        return obj.author == request.user or request.user.is_superuser
