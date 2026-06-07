from django import forms
from django.contrib.auth.forms import AuthenticationForm

from apps.merchants.models import StoreInvitation, StoreProfile
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


class StoreProfileForm(forms.ModelForm):
    latitude = forms.FloatField(
        required=False,
        widget=forms.NumberInput(attrs={'id': 'id_latitude', 'step': 'any', 'class': 'form-control'})
    )
    longitude = forms.FloatField(
        required=False,
        widget=forms.NumberInput(attrs={'id': 'id_longitude', 'step': 'any', 'class': 'form-control'})
    )

    class Meta:
        model = StoreProfile
        fields = ['business_name', 'merchant_type', 'description', 'street_address', 'halal', 'vegan']

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if self.instance and self.instance.location:
            self.fields['latitude'].initial = self.instance.latitude
            self.fields['longitude'].initial = self.instance.longitude
            
        self.fields['business_name'].initial = self.instance.business_name if self.instance.business_name else ""
        self.fields['description'].initial = self.instance.description if self.instance.description else ""
        self.fields['halal'].initial = self.instance.halal if self.instance.halal is not None else False
        self.fields['vegan'].initial = self.instance.vegan if self.instance.vegan is not None else False

    def save(self, commit=True):
        instance = super().save(commit=False)

        lat = self.cleaned_data.get('latitude')
        lon = self.cleaned_data.get('longitude')
        instance.set_coordinates(lat, lon)

        if commit:
            instance.save()

        return instance