# Generated by Django 2.2.3 on 2019-12-20 15:27

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('main', '0006_auto_20191220_1318'),
    ]

    operations = [
        migrations.AddField(
            model_name='complaint',
            name='status_message',
            field=models.CharField(default='', max_length=50),
        ),
    ]
