from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('merchants', '0010_storeprofile_street_address'),
    ]

    operations = [
        migrations.AddField(
            model_name='storeprofile',
            name='image',
            field=models.ImageField(blank=True, upload_to='merchants/stores/'),
        ),
    ]
