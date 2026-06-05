from typing import Any, cast
from django import forms
from .models import ItemCategory, Promotion, StoreItem


BASIC_FIELDS = ["name", "description", "price", "category", "stock_status"]
NUTRITION_FIELDS = ["calories"]
DIETARY_FIELDS = [
    "vegetarian",
    "organic",
    "gluten_free",
    "dairy_free",
    "contains_nuts",
]
SUSTAINABILITY_FIELDS = ["eco_packaging", "locally_sourced"]
META_FIELDS = ["thumbnail", "is_active"]


class CategoryNameChoiceField(forms.ModelChoiceField):
    def label_from_instance(self, obj: Any) -> str:
        # Cast obj to ItemCategory purely for type safety
        category = cast(ItemCategory, obj)
        return category.name


class StoreItemForm(forms.ModelForm):
    category = CategoryNameChoiceField(queryset=ItemCategory.objects.all())

    class Meta:
        model = StoreItem
        fields = BASIC_FIELDS + NUTRITION_FIELDS + DIETARY_FIELDS + SUSTAINABILITY_FIELDS + META_FIELDS
        labels = {
            "name": "Item Name",
            "is_active": "Show on platform"
        }
        help_texts = {
            "price": "Enter base price before tax.",
        }
        widgets = {
          "name": forms.TextInput(attrs={"placeholder": "e.g. Nasi Lemak"}),
          "description": forms.Textarea(attrs={"placeholder": "Brief description..."}),
          "price": forms.NumberInput(attrs={"placeholder": "0.00"}),
          "calories": forms.NumberInput(attrs={"placeholder": "kcal"}),
          "thumbnail": forms.FileInput(),
        }

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        
        category_field = cast(forms.ModelChoiceField, self.fields["category"])
        category_field.empty_label = None

        if not self.is_bound and category_field.queryset is not None:
            first_category = category_field.queryset.first()
            if first_category is not None:
                category_field.initial = first_category.pk
        
        self.grouped_fields = [
            ("", [self[name] for name in BASIC_FIELDS]),
            ("", [self[name] for name in NUTRITION_FIELDS]),
            ("Dietary Tags", [self[name] for name in DIETARY_FIELDS]),
            ("Sustainability", [self[name] for name in SUSTAINABILITY_FIELDS]),
            ("", [self[name] for name in META_FIELDS]),
        ]


class ItemCategoryForm(forms.ModelForm):
    class Meta:
        model = ItemCategory
        fields = ["name", "display_order"]


class PromotionForm(forms.ModelForm):
    class Meta:
        model = Promotion
        fields = [
            'title', 'description', 'promotion_type', 
            'promotion_amount', 'minimum_purchase_amount', 
            'eligible_items', 'reward_item', 'bundle_items', 
            'bundle_description', 'start_date', 'end_date'
        ]
        widgets = {
            # Render as Radio Buttons instead of a dropdown
            'promotion_type': forms.RadioSelect(attrs={'class': 'promo-type-radio sr-only'}),
            'start_date': forms.DateInput(attrs={'type': 'date'}),
            'end_date': forms.DateInput(attrs={'type': 'date'}),
        }
    
    def __init__(self, *args, **kwargs):
        self.store = kwargs.pop('store', None)
        super().__init__(*args, **kwargs)

        if self.store:
            store_items = StoreItem.objects.filter(store=self.store)
            
            eligible_items_field = cast(forms.ModelMultipleChoiceField, self.fields['eligible_items'])
            eligible_items_field.queryset = store_items
            
            reward_item_field = cast(forms.ModelChoiceField, self.fields['reward_item'])
            reward_item_field.queryset = store_items
            
            bundle_items_field = cast(forms.ModelMultipleChoiceField, self.fields['bundle_items'])
            bundle_items_field.queryset = store_items

    def clean(self):
        cleaned_data = super().clean()
        promo_type = cleaned_data.get("promotion_type")
        bundle_items = cleaned_data.get("bundle_items")

        # Validate ManyToMany field for Bundles
        if promo_type == Promotion.PromotionType.BUNDLE:
            if not bundle_items or not bundle_items.exists():
                self.add_error('bundle_items', "Please select at least one item for this bundle.")
        else:
            # If switched from Bundle to Percentage, 
            # clear out the bundle_items so Django doesn't save them
            cleaned_data['bundle_items'] = []
            
        # Sanitise eligible_items if it's a Bundle
        if promo_type == Promotion.PromotionType.BUNDLE:
            cleaned_data['eligible_items'] = []

        return cleaned_data