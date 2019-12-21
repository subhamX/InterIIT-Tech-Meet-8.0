from django.shortcuts import render,get_object_or_404
from django.views.generic import ListView,DetailView,CreateView,UpdateView,DeleteView
from django.contrib.auth.mixins import LoginRequiredMixin,UserPassesTestMixin
from .models import Complaint,Roads
from django.contrib.auth.models import User
from django.core.mail import send_mail
from PIL import Image
# Create your views here.

def main(request):
    return render(request,'main/home.html',context={'title': 'Welcome','complaints':Complaint.objects.all(),'roads':Roads.objects.all(),'cpts':Complaint.objects.filter(status=2)})

class ComplaintCreateView(LoginRequiredMixin,CreateView):
    model=Complaint
    fields=['road','rating','image','suggestions']
    def form_valid(self,form):
        form.instance.registered_by=self.request.user
        
       
        road=form.instance.road
        send_mail('Complaint Filed for road : '+str(road),'Dear User,\n Kindly note that your complaint has been registered Succesfully.Thanks for using Road Assist','parasgoyal13@gmail.com',[self.request.user.email],fail_silently=False)
        if not self.request.user.complaint_set.filter(road=road):
            
            
            road.complaints=road.complaints+1
            road.save()
        return super().form_valid(form)

class ComplaintDetailView(LoginRequiredMixin,UserPassesTestMixin,DetailView):
    model=Complaint
    def test_func(self):

        complaint=self.get_object()
        if(complaint.registered_by == self.request.user or self.request.user.is_superuser):
            return True
        else:
            return False

# class ComplaintListView(LoginRequiredMixin,UserPassesTestMixin,ListView):
#     model=Complaint
#     ordering=['-date_posted']
#     def test_func(self):
#         return self.request.user.is_superuser

class ComplaintListView(LoginRequiredMixin,UserPassesTestMixin,ListView):
    model=Complaint
    ordering=['-date_posted']
    def test_func(self):
        return self.request.user.is_superuser
    def get_queryset(self):
        road=Roads.objects.filter(id=int(self.kwargs.get('pk'))).last()
        result=Complaint.objects.filter(road=road,status=int(self.kwargs.get('status')))
        print(result)
        return result


class RoadListView(LoginRequiredMixin,UserPassesTestMixin,ListView):
    model=Roads
    ordering=['-complaints']
    def test_func(self):
        return self.request.user.is_superuser

class UserComplaintListView(LoginRequiredMixin,UserPassesTestMixin,ListView):
    model=Complaint
    def test_func(self):
        # print(self.kwargs.get('username'))
        if(str(self.kwargs.get('username')) == str(self.request.user)):
            return True
        else:
            return False
    def get_queryset(self):
        user = get_object_or_404(User,username=self.kwargs.get('username'))
        print(Complaint.objects.filter(registered_by=user).order_by('-date_posted'))
        return Complaint.objects.filter(registered_by=user).order_by('-date_posted')

class ComplaintUpdateView(LoginRequiredMixin,UserPassesTestMixin,UpdateView):
    model=Complaint
    fields=['status','status_message']
    # form_class=PostForm
    def form_valid(self,form):
        # form.instance.author=self.request.user
        road=form.instance.road
        complaint=Complaint.get_absolute_url(Complaint.objects.get(id=self.kwargs.get('pk')))
        complaint=self.request.build_absolute_uri(complaint)
        send_mail('Complaint Status Updated for: '+str(road),'Dear User,\n Kindly note that your complaint has been updated. You can view the status of your complaint on '+str(complaint) +'\nThanks for using Road Assist\n\n Regards','parasgoyal13@gmail.com',[self.request.user.email],fail_silently=False)

        road.complaints=road.complaints-1
        road.save()
        return super().form_valid(form)
    def test_func(self):
       
        if self.request.user.is_superuser:
            return True
        else:
            return False