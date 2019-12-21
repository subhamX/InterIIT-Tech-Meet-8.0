from django.shortcuts import render,redirect
from django.contrib import messages
from .forms import UserRegisterForm
from roadassist.settings import auth,firestore
import datetime
from django.contrib.auth.views import LoginView
# Create your views here.

def register(request):
    if request.method=='POST':
        form=UserRegisterForm(request.POST)
        if form.is_valid():
            cleaned_data=form.clean()
            auth.create_user(uid= cleaned_data['email']+'admin', email = cleaned_data['email'], display_name= cleaned_data['username'], password=cleaned_data['password1'])
            firestore.collection('users').document(cleaned_data['email']).set({
            'username': cleaned_data['username'],
            'email': cleaned_data['email'],
            'signup_timestamp': datetime.datetime.now(),
            })
          
            form.save()
            messages.success(request,"Your account has been created you are now able to Log In")
            return redirect('login')
    else:
        form = UserRegisterForm()
    return render(request,'users/register.html',{'form':form})

