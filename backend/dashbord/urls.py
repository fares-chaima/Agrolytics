"""
URL configuration for dashbord project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path
from . import views
from .views import soil_data

from .views import market_trends
from .views import calculate_agricultural_income


urlpatterns = [
    path('admin/', admin.site.urls),
     path('agriculture/advice/', views.get_agriculture_advice, name='get_agriculture_advice'),
         path('get_agriculture_recommendations/', views.get_agriculture_recommendations, name='get_agriculture_recommendations'),
          path('get_weather_forecast/', views.get_weather_forecast, name='get_weather_forecast'),
 path('agriculture/evaluation/', views.get_agriculture_evaluation, name='agriculture_evaluation'),
path('soil-data/', views.soil_data, name='soil_data'),

 path('agriculture/ev/', views.get_agriculture_ev, name='agriculture_ev'),
   path('api/market-trends/', market_trends, name='market-trends'),
    path('api/agriculture/', calculate_agricultural_income, name='calculate_agricultural_income'),

   path('api/iot-sensors/', views.iot_sensors, name='iot_sensors'),
  path('api/iot-sensor/', views.iot_sensor, name='iot_sensor'),


]
