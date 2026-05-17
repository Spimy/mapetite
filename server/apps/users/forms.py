from django import forms
from django.contrib.auth.forms import AuthenticationForm
from .models import User, UserProfile


class SignInForm(AuthenticationForm):
    error_messages = {
        "invalid_login": ("The username or password you have entered is invalid."),
        "inactive": ("This account is inactive."),
    }

    def __init__(self, *args, **kwargs):
        super(SignInForm, self).__init__(*args, **kwargs)
        self.label_suffix = ""

    username = forms.CharField(
        label="Email or Username",
        widget=forms.widgets.TextInput(attrs={"placeholder": "name@example.com"}),
    )

    password = forms.CharField(
        label="Password",
        widget=forms.widgets.PasswordInput(attrs={"placeholder": "Password"}),
    )
