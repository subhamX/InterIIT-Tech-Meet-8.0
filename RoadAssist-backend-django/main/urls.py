from django.urls import path
from .views import main,ComplaintCreateView,ComplaintDetailView,ComplaintListView,UserComplaintListView,RoadListView,ComplaintUpdateView

urlpatterns=[
    path('',main,name='homepage'),
    path('create_complaint/',ComplaintCreateView.as_view(),name='complaint-create'),
    path('complaint_detail/<int:pk>/',ComplaintDetailView.as_view(),name='complaint-detail'),
    path('complaint_list_all/<int:pk>/<int:status>',ComplaintListView.as_view(),name='complaint-list'),
    path('complaint_list/<str:username>',UserComplaintListView.as_view(),name='user-complaints'),
    path('road_list/',RoadListView.as_view(),name='road-list'),
    path('complaint-update/<int:pk>',ComplaintUpdateView.as_view(),name='complaint-update')
]