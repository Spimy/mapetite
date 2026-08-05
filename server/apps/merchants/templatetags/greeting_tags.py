from django import template
from django.utils import timezone

register = template.Library()


@register.simple_tag
def time_greeting():
    h = timezone.localtime().hour
    return "Good morning" if h < 12 else "Good afternoon" if h < 18 else "Good evening"
