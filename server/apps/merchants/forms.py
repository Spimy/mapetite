from typing import Any, cast
from django import forms
from .models import ItemCategory, StoreItem


BASIC_FIELDS = ["name", "description", "price", "category", "stock_status"]
NUTRITION_FIELDS = ["calories"]
DIETARY_FIELDS = [
    "halal",
    "vegan",
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
            ("Nutrition", [self[name] for name in NUTRITION_FIELDS]),
            ("Dietary Tags", [self[name] for name in DIETARY_FIELDS]),
            ("Sustainability", [self[name] for name in SUSTAINABILITY_FIELDS]),
            ("", [self[name] for name in META_FIELDS]),
        ]

class ItemCategoryForm(forms.ModelForm):
    class Meta:
        model = ItemCategory
        fields = ["name", "display_order"]
