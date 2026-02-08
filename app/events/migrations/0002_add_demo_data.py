from django.db import migrations
from datetime import date, timedelta


def create_demo_events(apps, schema_editor):
    Event = apps.get_model("events", "Event")

    events_list = []
    events_list.append(
        Event(
            title="Зустріч з друзями",
            description="Обговорення ідей для стартапу. Кафе Візит.",
            date=date.today() + timedelta(days=1),
        )
    )
    events_list.append(
        Event(
            title="Кінопрем'єра Посейдон",
            description="Кінотеатр Ліхтар. Велика премєра нового фільму.",
            date=date.today() + timedelta(days=3),
        )
    )

    Event.objects.bulk_create(events_list)


def remove_demo_events(apps, schema_editor):
    Event = apps.get_model("events", "Event")
    Event.objects.filter(title__startswith="Демонстраційна подія").delete()


class Migration(migrations.Migration):

    dependencies = [
        ("events", "0001_initial"),
    ]

    operations = [
        migrations.RunPython(create_demo_events, remove_demo_events),
    ]
