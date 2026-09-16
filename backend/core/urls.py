"""
URL configuration for core project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/6.0/topics/http/urls/
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
from django.conf import settings
from django.contrib import admin
from django.urls import include, path, re_path
from django.views.static import serve

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include('cuentas.urls')),
    path('api/', include('comunidades.urls')),
    path('api/', include('eventos.urls')),
    path('api/', include('solicitudes.urls')),
    # Logos y miniaturas se sirven siempre, tambien con DEBUG=False: el
    # helper static() de Django es un no-op en produccion y whitenoise solo
    # cubre STATIC_ROOT, asi que sin esto los logos daban 404 en Coolify.
    # Son archivos versionados en el repo (no subidas de usuarios), asi que
    # servirlos desde Django alcanza para este volumen.
    re_path(r'^media/(?P<path>.*)$', serve, {'document_root': settings.MEDIA_ROOT}),
]
