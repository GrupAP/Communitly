from django.contrib.auth.models import User
from django.db import models


class Categoria(models.Model):
    nombre = models.CharField(max_length=50, unique=True)

    def __str__(self):
        return self.nombre


class Facultad(models.Model):
    # sigla ("FIEC") o "Multi-facultad" para clubes institucionales que no
    # pertenecen a una sola facultad (p. ej. ligas deportivas, clubes de
    # emprendimiento vinculados a i3lab, etc.)
    nombre = models.CharField(max_length=20, unique=True)
    descripcion = models.CharField(max_length=150, blank=True)

    class Meta:
        verbose_name_plural = 'facultades'
        ordering = ['nombre']

    def __str__(self):
        return self.nombre


class Comunidad(models.Model):
    class NivelActividad(models.TextChoices):
        ACTIVO = 'activo', 'Activo'
        POCO_ACTIVO = 'poco_activo', 'Poco activo'
        INACTIVO = 'inactivo', 'Inactivo'
        SIN_VERIFICAR = 'sin_verificar', 'Sin verificar'

    nombre = models.CharField(max_length=120)
    descripcion = models.TextField()
    categoria = models.ForeignKey(Categoria, on_delete=models.PROTECT, related_name='comunidades')
    facultad = models.ForeignKey(
        Facultad, on_delete=models.PROTECT, related_name='comunidades',
        null=True, blank=True,
    )
    contacto = models.EmailField(blank=True)
    instagram = models.URLField(blank=True)
    # que tan activo esta el club en redes; se usa para mostrar señal de
    # vigencia real a estudiantes de colegio que exploran el catalogo
    nivel_actividad = models.CharField(
        max_length=20,
        choices=NivelActividad.choices,
        default=NivelActividad.SIN_VERIFICAR,
    )
    # Ficha informativa opcional: no todos los clubes tienen (o nos dieron)
    # estos datos, asi que quedan en blanco en vez de forzar un valor. La
    # vista publica solo muestra las filas que si tengan contenido.
    carrera = models.CharField(max_length=150, blank=True)
    fundado = models.CharField(max_length=20, blank=True)
    reuniones = models.CharField(max_length=150, blank=True)
    lugar_reuniones = models.CharField(max_length=150, blank=True)
    membresia = models.CharField(max_length=150, blank=True)
    activa = models.BooleanField(default=True)
    creada_en = models.DateTimeField(auto_now_add=True)
    # responsables de la comunidad; controlan eventos (RF-04) y solicitudes (RF-06)
    gestores = models.ManyToManyField(User, related_name='comunidades_gestionadas', blank=True)

    class Meta:
        ordering = ['nombre']
        verbose_name_plural = 'comunidades'

    def __str__(self):
        return self.nombre

    def total_seguidores(self):
        return self.seguidores.count()


class PublicacionInstagram(models.Model):
    """Post curado a mano para el carrusel de "actividad reciente" del
    detalle publico: Instagram no deja traer las fotos de una cuenta ajena
    sin OAuth, asi que un gestor pega aqui la URL de publicaciones puntuales
    para incrustarlas con el embed publico de Instagram (sin token)."""

    comunidad = models.ForeignKey(
        Comunidad, on_delete=models.CASCADE, related_name='publicaciones_instagram',
    )
    url = models.URLField()
    orden = models.PositiveSmallIntegerField(default=0)
    agregada_en = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['orden', 'agregada_en']

    def __str__(self):
        return f'{self.comunidad.nombre}: {self.url}'


class Seguimiento(models.Model):
    estudiante = models.ForeignKey(User, on_delete=models.CASCADE, related_name='seguimientos')
    comunidad = models.ForeignKey(Comunidad, on_delete=models.CASCADE, related_name='seguidores')
    fecha = models.DateTimeField(auto_now_add=True)

    class Meta:
        # un estudiante no puede seguir dos veces la misma comunidad
        constraints = [
            models.UniqueConstraint(fields=['estudiante', 'comunidad'], name='seguimiento_unico')
        ]

    def __str__(self):
        return f'{self.estudiante.username} sigue a {self.comunidad.nombre}'
