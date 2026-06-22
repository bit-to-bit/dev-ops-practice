from django.db import models


class Event(models.Model):
    title = models.CharField(max_length=200, verbose_name="Назва події")
    description = models.TextField(verbose_name="Опис")
    date = models.DateField(verbose_name="Дата події")
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.title} ({self.date})"

    class Meta:
        verbose_name = "Подія"
        verbose_name_plural = "Події"
        ordering = ["date"]
