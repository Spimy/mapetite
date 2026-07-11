from django.contrib.auth import get_user_model
from django.contrib.auth.backends import ModelBackend
from django.db.models import Q


class EmailOrUsernameBackend(ModelBackend):
    """
    Allow active users to authenticate using a case-insensitive username
    or email address.
    """

    def authenticate(self, request, username=None, password=None, **kwargs):
        user_model = get_user_model()

        identifier = username or kwargs.get(user_model.USERNAME_FIELD)

        if not identifier or password is None:
            return None

        username_lookup = f"{user_model.USERNAME_FIELD}__iexact"

        try:
            user = user_model.objects.get(
                Q(**{username_lookup: identifier}) |
                Q(email__iexact=identifier)
            )
        except user_model.DoesNotExist:
            user_model().set_password(password)
            return None

        if user.check_password(password) and self.user_can_authenticate(user):
            return user

        return None