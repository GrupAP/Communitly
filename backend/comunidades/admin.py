from django.contrib import admin

from .models import Categoria, Comunidad, Facultad, PublicacionInstagram, Seguimiento


@admin.register(Categoria)
class CategoriaAdmin(admin.ModelAdmin):
    list_display = ['nombre']


@admin.register(Facultad)
class FacultadAdmin(admin.ModelAdmin):
    list_display = ['nombre', 'descripcion']


class PublicacionInstagramInline(admin.TabularInline):
    model = PublicacionInstagram
    fields = ['titulo', 'url', 'imagen', 'orden']
    extra = 1


@admin.register(Comunidad)
class ComunidadAdmin(admin.ModelAdmin):
    list_display = ['nombre', 'categoria', 'facultad', 'nivel_actividad', 'activa']
    list_filter = ['categoria', 'facultad', 'nivel_actividad', 'activa']
    search_fields = ['nombre', 'descripcion']
    inlines = [PublicacionInstagramInline]
    fieldsets = [
        (None, {'fields': ['nombre', 'descripcion', 'categoria', 'facultad', 'logo', 'activa']}),
        ('Contacto y redes', {'fields': ['contacto', 'instagram', 'nivel_actividad']}),
        ('Ficha informativa (opcional, deja en blanco lo que no sepas)', {
            'fields': ['carrera', 'fundado', 'reuniones', 'lugar_reuniones', 'membresia'],
        }),
    ]


@admin.register(Seguimiento)
class SeguimientoAdmin(admin.ModelAdmin):
    list_display = ['estudiante', 'comunidad', 'fecha']
