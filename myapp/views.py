from django.shortcuts import render

# Create your views here.

from .models import Product

def home(request):
    products = Product.objects.all()
    return render(request, 'home.html', {'products': products})
