from typing import Any
from django.core.paginator import Paginator, Page, InvalidPage

class Template404Paginator(Paginator):
    """
    Custom paginator that catches out-of-bounds page requests 
    and returns an empty Page object instead of throwing an Http404.
    """
    def page(self, number: Any) -> Page:
        try:
            return super().page(number)
        except InvalidPage:
            # Feed it an empty list to trigger the template's {% empty %} block
            return Page([], number, self)