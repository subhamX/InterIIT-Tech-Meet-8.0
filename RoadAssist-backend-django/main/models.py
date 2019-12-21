from django.db import models
from django.utils import timezone
from django.contrib.auth.models import User
from django.urls import reverse
from PIL import Image
# from .apps import MainConfig
# import numpy as np
# from tensorflow.keras.preprocessing import image
# Create your models here.
class Places(models.Model):
    name=models.CharField(max_length=20)

    def __str__(self):
        return self.name
    class Meta:
        verbose_name_plural='Places'
class Roads(models.Model):
    start=models.ForeignKey(Places,on_delete=models.CASCADE)
    end=models.ForeignKey(Places,on_delete=models.CASCADE,related_name='place_of_road_ending')
    tender_alloted_to=models.CharField(max_length=30)
    complaints=models.IntegerField(default=0)
    
    def __str__(self):
        return self.start.name+" " +self.end.name
    
    class Meta:
        verbose_name_plural='Roads'

class Complaint(models.Model):
    road=models.ForeignKey(Roads,on_delete=models.CASCADE)
    registered_by=models.ForeignKey(User,on_delete=models.CASCADE)
    status_choices=(('0','Just Arrived'),('1','In Progress'),('2','Resolved'))
    date_posted=models.DateTimeField(default=timezone.now)
    status=models.CharField(max_length=1,choices=status_choices,default='0')
    status_message=models.CharField(max_length=50,default="")
    rating=models.CharField(max_length=1,choices=(('1','Very Poor'),('2','Below Average'),('3','Average'),('4','Minor issues'),('5','Fine but can be improved')))
    image=models.ImageField(null=True,blank=True,upload_to='images',default="images/default.jpg")
    suggestions=models.TextField(null=True)
    # damage=models.IntegerField(null=True,blank=True,default=0)
    def __str__(self):
        return self.road.start.name+" "+self.road.end.name+" "+self.registered_by.username
    
    class Meta:
        verbose_name_plural='Complaints'

    def get_absolute_url(self):
        return reverse('complaint-detail',kwargs={'pk':self.pk})
    
    def save(self,*args,**kwargs):
        super().save(*args,**kwargs)
        img=Image.open(self.image.path)
        if img.height>150 or img.width>150:
            output_size=(150,150)
            img.thumbnail(output_size)
            img.save(self.image.path)
        # img=image.img_to_array(image.load_img(self.image.path,target_size=(150,150)))
        # img=np.expand_dims(img,axis=0)
        # self.damage=(1-MainConfig.model.predict(img))*100
        # super().save(*args,**kwargs)