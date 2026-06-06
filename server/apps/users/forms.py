from django import forms
from django.contrib.auth.forms import AuthenticationForm
from .models import User, UserProfile


class SignInForm(AuthenticationForm):
    error_messages = {
        "invalid_login": ("Incorrect email/username or password."),
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
        widget=forms.widgets.PasswordInput(attrs={"placeholder": "••••••••"}),
    )


class UserInfoForm(forms.ModelForm):
    owner_name = forms.CharField(label="Owner Name", required=False)
    email = forms.EmailField(label="Email", required=False)

    class Meta:
        model = UserProfile
        fields = ["avatar", "phone_number", "address", "city", "country"]

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        user = self.instance.user
        full_name = f"{user.first_name} {user.last_name}".strip()
        
        self.fields['owner_name'].initial = full_name if full_name else user.username
        self.fields['owner_name'].widget.attrs['readonly'] = True
        self.fields['owner_name'].widget.attrs['disabled'] = True

        self.fields['email'].initial = user.email
        self.fields['email'].widget.attrs['readonly'] = True
        self.fields['email'].widget.attrs['disabled'] = True

    def save(self, commit=True):
        return super().save(commit=commit)