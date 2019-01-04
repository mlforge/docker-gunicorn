from django.urls import path

from . import views

urlpatterns = [
    path('', views.HelloAPIView().as_view())
]