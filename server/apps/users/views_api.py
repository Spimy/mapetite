from allauth.socialaccount.providers.google.views import GoogleOAuth2Adapter
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser, JSONParser
from rest_framework.exceptions import ValidationError
from drf_spectacular.utils import extend_schema_view, extend_schema
from allauth.socialaccount.providers.oauth2.client import OAuth2Client, OAuth2Error
from dj_rest_auth.registration.views import (
    APIView,
    IsAuthenticated,
    SocialLoginView,
    VerifyEmailView,
)
from .serializers import (
    CustomGoogleLoginSerializer,
    UserDetailSerializer,
    UserProfileUpdateSerializer,
)


class GoogleLoginView(SocialLoginView):
    """Takes the access token from the frontend provided by Google and uses it to log in the user via Google OAuth2"""

    adapter_class = GoogleOAuth2Adapter
    client_class = OAuth2Client
    authentication_classes = []
    serializer_class = CustomGoogleLoginSerializer

    # Override to avoid creating cookies since we are using JWTs for authentication
    def post(self, request, *args, **kwargs):
        try:
            response = super().post(request, *args, **kwargs)

            if hasattr(request, "_messages"):
                request._messages.added_new = False

            if hasattr(request, "session"):
                request.session.modified = False

            return response
        except OAuth2Error as err:
            raise ValidationError({"detail": str(err) or "Invalid token provided."})
        except Exception as err:
            if "Audience doesn't match" in str(err) or "Invalid id_token" in str(err):
                raise ValidationError(
                    {"detail": "Invalid token audience or signature."}
                )
            raise err


@extend_schema_view(
    post=extend_schema(
        exclude=True  # This hides the dummy route entirely from Swagger/ReDoc
    )
)
class HiddenDummyVerifyView(VerifyEmailView):
    """
    Used for the allauth dummy route. We hide it so it doesn't clutter the API docs.
    """

    pass


class UserDetailView(APIView):
    """API view to get details of the currently authenticated user"""

    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    @extend_schema(responses={200: UserDetailSerializer})
    def get(self, request, *args, **kwargs):
        serializer = UserDetailSerializer(request.user)
        return Response(serializer.data)

    @extend_schema(
        request=UserProfileUpdateSerializer, responses={200: UserDetailSerializer}
    )
    def patch(self, request, *args, **kwargs):
        serializer = UserProfileUpdateSerializer(
            instance=request.user,
            data=request.data,
            partial=True,
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()

        request.user.refresh_from_db()
        request.user.user_profile.refresh_from_db()

        return Response(UserDetailSerializer(request.user).data)
