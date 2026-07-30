from django import forms


class ContactForm(forms.Form):
    business_name = forms.CharField(
        max_length=100,
        required=True,
        label="Business Name",
        widget=forms.TextInput(attrs={"placeholder": "e.g. Green Leaf Cafe"}),
    )
    business_type = forms.ChoiceField(
        choices=[
            ("restaurant", "Restaurant"),
            ("grocery", "Grocery"),
        ],
        required=True,
        label="Business Type",
        widget=forms.Select(attrs={"placeholder": "Select Type..."}),
    )
    contact_person = forms.CharField(
        max_length=100,
        required=True,
        label="Contact Person",
        widget=forms.TextInput(attrs={"placeholder": "Full Name"}),
    )
    phone_number = forms.CharField(
        max_length=15,
        required=True,
        label="Phone Number",
        widget=forms.TextInput(attrs={"placeholder": "e.g. +60 xxx-xx xxxx"}),
    )
    email = forms.EmailField(
        required=True,
        label="Email Address",
        widget=forms.EmailInput(attrs={"placeholder": "you@company.com"}),
    )
    message = forms.CharField(
        required=False,
        label="Message",
        widget=forms.Textarea(attrs={"placeholder": "Your message here..."}),
    )
