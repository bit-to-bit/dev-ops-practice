from django import forms
from .models import Event


class EventForm(forms.ModelForm):
    class Meta:
        model = Event
        fields = ["title", "description", "date"]
        widgets = {
            "date": forms.DateInput(attrs={"type": "date", "class": "form-control"}),
        }
