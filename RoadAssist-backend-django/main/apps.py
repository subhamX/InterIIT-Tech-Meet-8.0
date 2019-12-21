from django.apps import AppConfig
# import tensorflow as tf
# flag=0
class MainConfig(AppConfig):
    name = 'main'
    # if flag==0:
    #     try:
    #         flag=1
    #         model=tf.keras.models.load_model('interiit.h5')

    #     except ImportError as e:
    #         print("Import Failed!")