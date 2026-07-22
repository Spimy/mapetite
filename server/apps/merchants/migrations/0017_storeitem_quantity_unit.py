import re
from decimal import Decimal, InvalidOperation

from django.db import migrations, models


UNIT_CHOICES = [
    ("g", "Grams (g)"),
    ("kg", "Kilograms (kg)"),
    ("ml", "Milliliters (ml)"),
    ("L", "Liters (L)"),
    ("pcs", "Pieces (pcs)"),
    ("tbsp", "Tablespoon (tbsp)"),
    ("tsp", "Teaspoon (tsp)"),
    ("cup", "Cup"),
]

VALID_UNITS = {value for value, _ in UNIT_CHOICES}

# Matches "100 g", "1.5 kg", "15 pcs", etc.
SIMPLE_PATTERN = re.compile(
    r"^\s*(?P<quantity>\d+(?:\.\d+)?)\s+(?P<unit>[A-Za-z]+)\s*$"
)
# Matches "1 tray of 30 pcs"
TRAY_PATTERN = re.compile(
    r"^\s*\d+\s+tray\s+of\s+(?P<quantity>\d+(?:\.\d+)?)\s+(?P<unit>pcs)\s*$",
    re.IGNORECASE,
)


def parse_unit_size(unit_size: str):
    if not unit_size or not unit_size.strip():
        return None, ""

    tray_match = TRAY_PATTERN.match(unit_size)
    if tray_match:
        return Decimal(tray_match.group("quantity")), tray_match.group("unit")

    simple_match = SIMPLE_PATTERN.match(unit_size)
    if not simple_match:
        return None, ""

    unit = simple_match.group("unit")
    if unit not in VALID_UNITS:
        return None, ""

    try:
        quantity = Decimal(simple_match.group("quantity"))
    except InvalidOperation:
        return None, ""

    return quantity, unit


def forwards_parse_unit_size(apps, schema_editor):
    StoreItem = apps.get_model("merchants", "StoreItem")
    for item in StoreItem.objects.all().iterator():
        quantity, unit = parse_unit_size(item.unit_size or "")
        item.quantity = quantity
        item.unit = unit
        item.save(update_fields=["quantity", "unit"])


def backwards_rebuild_unit_size(apps, schema_editor):
    StoreItem = apps.get_model("merchants", "StoreItem")
    for item in StoreItem.objects.all().iterator():
        if item.quantity is None or not item.unit:
            item.unit_size = ""
        else:
            quantity_str = f"{item.quantity:.2f}".rstrip("0").rstrip(".")
            item.unit_size = f"{quantity_str} {item.unit}"
        item.save(update_fields=["unit_size"])


class Migration(migrations.Migration):

    dependencies = [
        ("merchants", "0016_storeprofile_category"),
    ]

    operations = [
        migrations.AddField(
            model_name="storeitem",
            name="quantity",
            field=models.DecimalField(
                blank=True, decimal_places=2, max_digits=8, null=True
            ),
        ),
        migrations.AddField(
            model_name="storeitem",
            name="unit",
            field=models.CharField(
                blank=True, choices=UNIT_CHOICES, max_length=10
            ),
        ),
        migrations.RunPython(forwards_parse_unit_size, backwards_rebuild_unit_size),
        migrations.RemoveField(
            model_name="storeitem",
            name="unit_size",
        ),
    ]
