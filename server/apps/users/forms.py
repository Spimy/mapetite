from django import forms
from django.contrib.auth.forms import AuthenticationForm

from apps.merchants.models import StoreInvitation
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
    
    
class InviteStaffForm(forms.ModelForm):
    class Meta:
        model = StoreInvitation
        fields = ['first_name', 'last_name', 'email']

    def clean_email(self):
        # Always save emails in lowercase to prevent case-sensitivity bugs
        return self.cleaned_data['email'].lower()


class UserInfoForm(forms.ModelForm):
    display_name = forms.CharField(
        label="Display Name",
        required=False,
        help_text="This is the name that will be shown in the dashboard to you. The owner will always see your first and last name unless they are not set, in which case they will see your username."
    )
    owner_name = forms.CharField(
        label="Owner Name", 
        required=False,
        help_text="Auto-filled from account registration. Updates only when ownership is transferred or you change your name in personal settings."
    )
    
    email = forms.EmailField(
        label="Email", 
        required=False,
        help_text="To change your email, contact Mapetite support."
    )

    class Meta:
        model = UserProfile
        fields = ["avatar", "phone_number", "address", "city", "country"]

    def __init__(self, *args, **kwargs):
        store = kwargs.pop('store', None)
        super().__init__(*args, **kwargs)

        user = self.instance.user
        full_name = f"{user.first_name} {user.last_name}".strip()
        
        self.fields['display_name'].initial = user.username if user.username else full_name if full_name else user.email
        
        if store and hasattr(store, 'owner'):
            owner = store.owner
            full_name = f"{owner.first_name} {owner.last_name}".strip()
            self.fields['owner_name'].initial = full_name if full_name else owner.username
        else:
            self.fields['owner_name'].initial = "Unknown Owner"
            
        self.fields['owner_name'].widget.attrs['readonly'] = True
        self.fields['owner_name'].widget.attrs['disabled'] = True

        self.fields['email'].initial = user.email
        self.fields['email'].widget.attrs['readonly'] = True
        self.fields['email'].widget.attrs['disabled'] = True

    def save(self, commit=True):
        profile = super().save(commit=False)
        user = profile.user
        
        if 'display_name' in self.cleaned_data:
            display_name = self.cleaned_data['display_name'].strip()
            user.username = display_name

        if commit:
            user.save()
            profile.save()
            
        return profile
