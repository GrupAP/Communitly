from django.contrib.auth.models import User
from django.core.management.base import BaseCommand

from comunidades.models import Categoria, Comunidad, Facultad

# Facultades de ESPOL con al menos un club en COMUNIDADES, mas "Multi-facultad"
# para comunidades institucionales/transversales que no viven en una sola
# facultad (verificado contra las paginas oficiales "Grupos Estudiantiles" de
# cada facultad; ver FACULTAD_POR_COMUNIDAD mas abajo).
FACULTADES = {
    'FIEC': 'Ingeniería en Electricidad y Computación',
    'FIMCP': 'Ingeniería Mecánica y Ciencias de la Producción',
    'FICT': 'Ingeniería en Ciencias de la Tierra',
    'FCNM': 'Ciencias Naturales y Matemáticas',
    'FCSH': 'Ciencias Sociales y Humanísticas',
    'FADCOM': 'Arte, Diseño y Comunicación Audiovisual',
    'FCV': 'Ciencias de la Vida',
    'Multi-facultad': 'Comunidad institucional abierta a estudiantes de cualquier facultad',
}

# nombre de la comunidad -> sigla de FACULTADES
FACULTAD_POR_COMUNIDAD = {
    'CIAP': 'FIEC',
    'TAWS': 'FIEC',
    'NIoT': 'FIEC',
    'KOKOA': 'FIEC',
    'PHYCOM': 'FIEC',
    'IEEE ESPOL Student Branch': 'FIEC',
    'Célula Estudiantil Microsoft ESPOL': 'FIEC',
    'ROBOTA': 'FIMCP',
    'CIMAT': 'FIMCP',
    'IFT ESPOL': 'FIMCP',
    'IISE ESPOL': 'FIMCP',
    'Club de Mecatrónica ESPOL': 'FIMCP',
    'AWS ESPOL': 'FIMCP',
    'ASME ESPOL': 'FIMCP',
    'ASHRAE ESPOL': 'FIMCP',
    'MAEC': 'FIMCP',
    'RAS ESPOL': 'FIMCP',
    'GISSC': 'FICT',
    'SPE ESPOL': 'FICT',
    'SME ESPOL': 'FICT',
    'AAPG ESPOL': 'FICT',
    'ACI ESPOL': 'FICT',
    'ASCE ESPOL': 'FICT',
    'IAHR ESPOL': 'FICT',
    'CLIP': 'FCNM',
    'D.A.T.A Club': 'FCNM',
    'MatEs': 'FCNM',
    'AIChE ESPOL': 'FCNM',
    'CADIEC': 'FCSH',
    'Club de Arqueología': 'FCSH',
    'Suitcase Club': 'FCSH',
    'BREIK': 'FADCOM',
    'Tweening': 'FADCOM',
    'Alucine': 'FADCOM',
    'D-PRO': 'FADCOM',
    'Politécnicas en STEAM': 'Multi-facultad',
    'Club Emprende': 'Multi-facultad',
    'Argumentum': 'Multi-facultad',
    'ACP': 'Multi-facultad',
    'FANPOL': 'Multi-facultad',
    'Liga Deportiva Politécnica': 'Multi-facultad',
    'Yaku Club de Buceo Investigativo': 'Multi-facultad',
    'BIOSOC ESPOL': 'FCV',
    'Kawsay': 'FCV',
    'AUCE': 'Multi-facultad',
    '593 Guides Club': 'FCSH',
}

# nombre de la comunidad -> archivo en backend/media/logos/ (logos reales
# subidos por el equipo; los clubes sin logo propio quedan sin imagen en vez
# de usar un placeholder generico).
LOGO_POR_COMUNIDAD = {
    'CIAP': 'ciap.png',
    'TAWS': 'taws.png',
    'NIoT': 'niot.png',
    'KOKOA': 'kokoa.png',
    'PHYCOM': 'phycom.png',
    'ROBOTA': 'robota.jpg',
    'IEEE ESPOL Student Branch': 'ieee.png',
    'GISSC': 'gissc.png',
    'CIMAT': 'cimat.jpg',
    'IFT ESPOL': 'ift.png',
    'IISE ESPOL': 'iise.png',
    'SPE ESPOL': 'spe.png',
    'SME ESPOL': 'sme.png',
    'CADIEC': 'cadiec.png',
    'CLIP': 'clip.png',
    'BREIK': 'breik.webp',
    'Club de Arqueología': 'arqueologia.jpg',
    'Club de Mecatrónica ESPOL': 'mecatronica.png',
    'Célula Estudiantil Microsoft ESPOL': 'celula.png',
    'AAPG ESPOL': 'aapg.jpg',
    'ASME ESPOL': 'asme.png',
    'ASCE ESPOL': 'asce.png',
    'Tweening': 'tweening.png',
    'Argumentum': 'argumentum.png',
    'ACP': 'acp.png',
    'FANPOL': 'fanpol.png',
    'AUCE': 'accion.png',
}

# (nombre, categoria, descripcion, contacto, activa, instagram, nivel_actividad)
#
# Verificado contra Instagram (fecha de referencia: sep-2026) para saber que
# tan vigente esta cada club antes de mostrarlo en el catalogo. Los clubes sin
# cuenta verificada quedan con instagram='' y nivel_actividad='sin_verificar'
# en vez de inventar un dato.
COMUNIDADES = [
    ('CIAP', 'Tecnología',
     'Club de Inteligencia Artificial Politécnico: promueve la investigación '
     'y el aprendizaje en IA y ciencia de datos mediante charlas, talleres, '
     'hackathons y proyectos colaborativos; reconocido entre los mejores '
     'clubes de ESPOL en 2023-2025.',
     'ciap@espol.edu.ec', True, 'https://www.instagram.com/ciap_espol/', 'activo'),
    ('TAWS', 'Tecnología',
     'Grupo estudiantil de investigación de ESPOL (FIEC) en tecnologías web, '
     'móviles, ciencia de datos, machine learning e IoT; organiza talleres, '
     'tutorías académicas y proyectos de investigación.',
     'taws@espol.edu.ec', True, 'https://www.instagram.com/taws_espol/', 'activo'),
    ('NIoT', 'Tecnología',
     'Club de ESPOL (FIEC) dedicado a la investigación e innovación en '
     'redes, internet de las cosas (IoT) y sistemas embebidos, mediante '
     'programas educativos y competencias.',
     'niot@espol.edu.ec', True, 'https://www.instagram.com/club.niot.espol/', 'activo'),
    ('KOKOA', 'Tecnología',
     'Comunidad de software libre de ESPOL que organiza talleres de '
     'programación, charlas relámpago, una feria anual de proyectos (IA, '
     'ciencia de datos, videojuegos) y participa en iniciativas globales '
     'como Hacktoberfest.',
     'kokoa@espol.edu.ec', True, 'https://www.instagram.com/kokoa_espol/', 'activo'),
    ('PHYCOM', 'Tecnología',
     'Club de Physical Computing de ESPOL (FIEC): combina electrónica, '
     'programación y sistemas interactivos mediante talleres, hackathons y '
     'proyectos interdisciplinarios, incluyendo programas para niños '
     '(Phycom Kids/JR).',
     'phycom@espol.edu.ec', True, 'https://www.instagram.com/phycom_espol/', 'activo'),
    ('ROBOTA', 'Tecnología',
     'Club de Robótica de ESPOL (FIMCP), equipo FRC 5814. Construye y '
     'compite con robots, organiza talleres y es anfitrión del concurso '
     'internacional "Reto del Pacífico".',
     'robota@espol.edu.ec', True, 'https://www.instagram.com/robotaespol/', 'activo'),
    ('IEEE ESPOL Student Branch', 'Tecnología',
     'Rama estudiantil de IEEE en ESPOL que agrupa varias sociedades '
     'técnicas afiliadas (Computer Society, IAS, EMBS, entre otras) y '
     'organiza charlas, concursos, reconocimientos y proyectos de '
     'ingeniería eléctrica y de la computación.',
     'ieee@espol.edu.ec', True, 'https://www.instagram.com/ieee.espol/', 'activo'),
    ('GISSC', 'Ciencias',
     'Geographic Information System Student Club: explora el uso de datos '
     'geoespaciales y sistemas de información geográfica (SIG) para el '
     'análisis territorial, con talleres para la comunidad "#GISLovers".',
     'gissc@espol.edu.ec', True, 'https://www.instagram.com/gissc_espol/', 'poco_activo'),
    # El nombre completo se estiliza "Ciencia" en singular (no "Ciencias") y el
    # club opera como carrera de FIMCP, por lo que encaja mejor en Ingeniería.
    ('CIMAT', 'Ingeniería',
     'Club de Ciencia e Ingeniería en Materiales (FIMCP): organiza talleres '
     'prácticos (p. ej. cerámica), charlas técnicas sobre aceros, bronces y '
     'polímeros, y difunde becas como ERASMUS.',
     'club_cimat@espol.edu.ec', True, 'https://www.instagram.com/club_cimat/', 'activo'),
    ('IFT ESPOL', 'Ciencias',
     'Primer capítulo estudiantil del Institute of Food Technologists en '
     'Ecuador y Sudamérica, vinculado a Ingeniería en Alimentos; organiza '
     'charlas, trivias, competencias (College Bowl) y actividades sociales.',
     'ift@espol.edu.ec', True, 'https://www.instagram.com/ift_espol/', 'activo'),
    ('Politécnicas en STEAM', 'Ciencias',
     'Comunidad que crea espacios de colaboración interdisciplinaria e '
     'integración para mujeres en ciencia, tecnología, ingeniería, arte y '
     'matemáticas (STEAM), bajo el lema "#InnovandoJuntas".',
     'steam@espol.edu.ec', True, 'https://www.instagram.com/politecnicas.steam/', 'poco_activo'),
    # El capitulo es el N.º 711, no el 771 (dato en la bio, posts y LinkedIn).
    ('IISE ESPOL', 'Ingeniería',
     'Capítulo estudiantil N.º 711 del Institute of Industrial and Systems '
     'Engineers: organiza charlas con la industria, trivias, jornadas de '
     'fotografía profesional y celebraciones institucionales (Día ISE).',
     'iise@espol.edu.ec', True, 'https://www.instagram.com/iise_espol/', 'activo'),
    ('SPE ESPOL', 'Ingeniería',
     'Capítulo estudiantil de la Society of Petroleum Engineers: charlas '
     'técnicas, webinars, visitas de campo al sector energético y '
     'competencias como PetroTest.',
     'spe@espol.edu.ec', True, 'https://www.instagram.com/espolspe/', 'activo'),
    ('SME ESPOL', 'Ingeniería',
     'Capítulo estudiantil enfocado en minería sostenible; organiza charlas '
     'técnicas, talleres y el congreso EcuaMining junto a la carrera de '
     'Minas de ESPOL.',
     'sme@espol.edu.ec', True, 'https://www.instagram.com/smeespol/', 'activo'),
    ('CADIEC', 'Negocios',
     'Club de Aplicación, Desarrollo e Investigaciones Económicas (2014): '
     'análisis económico, seminarios y publicaciones, con contenido '
     'educativo regular en redes.',
     'cadiec@espol.edu.ec', True, 'https://www.instagram.com/cadiecespol/', 'activo'),
    # Nombre oficial correcto: "Integral", no "Mercantil" (bio de Instagram y
    # LinkedIn); el handle real es clip_espol, no "clip".
    ('CLIP', 'Negocios',
     'Club Logístico Integral Politécnico: capacitaciones, visitas técnicas '
     'y eventos estudiantiles sobre logística, comercio exterior y cadena '
     'de suministro.',
     'clip@espol.edu.ec', True, 'https://www.instagram.com/clip_espol/', 'activo'),
    ('BREIK', 'Arte',
     'Club de comunicación audiovisual de ESPOL (FADCOM) dedicado a la '
     'creación de contenido, cobertura de eventos y producciones '
     'audiovisuales; ofrece también talleres y servicios de producción.',
     'breik@espol.edu.ec', True, 'https://www.instagram.com/breikgye/', 'activo'),
    # Su Instagram muestra publicaciones regulares durante 2026 (charlas,
    # talleres, ferias): esta activo, pese a lo que sugeria un dato anterior.
    ('Club de Arqueología', 'Cultura',
     'Comunidad estudiantil dedicada a la difusión del patrimonio '
     'arqueológico mediante charlas, talleres, ferias y actividades de '
     'divulgación (CICEAI).',
     'arqueologia@espol.edu.ec', True, 'https://www.instagram.com/clubarqueologia.espol/', 'activo'),

    # --- Clubes nuevos (no estaban en la base; confianza alta: pagina oficial
    # de facultad o nota de prensa ESPOL). No hay un directorio unico oficial
    # de ESPOL, asi que esto no agota los ~40 clubes que mencionan tener. ---
    ('Club de Mecatrónica ESPOL', 'Tecnología',
     'Club estudiantil de la Facultad de Ingeniería Mecánica (FIMCP) '
     'enfocado en robótica, IoT, manufactura aditiva y automatización; '
     'organiza talleres de suelda y competencias de robótica como '
     'Robomatrix.',
     '', True, 'https://www.instagram.com/club_mecatronica_espol/', 'activo'),
    ('RAS ESPOL', 'Tecnología',
     'Robotics & Automation Society: capítulo técnico de IEEE ESPOL '
     'enfocado en robótica y automatización, distinto del club Robota.',
     '', True, '', 'sin_verificar'),
    ('Célula Estudiantil Microsoft ESPOL', 'Tecnología',
     'Comunidad estudiantil de FIEC centrada en ingeniería de software, '
     'robótica e interacción humano-computadora usando tecnologías '
     'Microsoft.',
     '', True, '', 'sin_verificar'),
    # No confundir con TAWS (comunidad de tecnologias web) ni con Amazon Web
    # Services: este es el capitulo de la American Welding Society.
    ('AWS ESPOL', 'Ingeniería',
     'Capítulo estudiantil de la American Welding Society en FIMCP, '
     'enfocado en soldadura.',
     '', True, '', 'sin_verificar'),
    ('D.A.T.A Club', 'Tecnología',
     'Data Analysis Technology Algorithms: club de la FCNM enfocado en '
     'estadística aplicada y análisis de datos interdisciplinario.',
     '', True, '', 'sin_verificar'),
    ('MatEs', 'Ciencias',
     'Club de la FCNM dedicado a la divulgación y competencias de '
     'matemáticas.',
     '', True, '', 'sin_verificar'),
    ('AAPG ESPOL', 'Ciencias',
     'Capítulo estudiantil de la American Association of Petroleum '
     'Geologists, enfocado en geología del petróleo (FICT).',
     '', True, '', 'sin_verificar'),
    ('Yaku Club de Buceo Investigativo', 'Ciencias',
     'Club de buceo científico que forma a estudiantes en ciencias marinas '
     'y certificación de buceo (CMAS/FEDASUB).',
     '', True, 'https://www.instagram.com/yakubuceo_espol/', 'activo'),
    ('ASME ESPOL', 'Ingeniería',
     'Capítulo estudiantil de la American Society of Mechanical Engineers '
     'en FIMCP.',
     '', True, '', 'sin_verificar'),
    ('ASHRAE ESPOL', 'Ingeniería',
     'Capítulo estudiantil ASHRAE de FIMCP enfocado en calefacción, '
     'ventilación, refrigeración y aire acondicionado.',
     '', True, '', 'sin_verificar'),
    ('MAEC', 'Ingeniería',
     'Mecánica Automotriz ESPOL Club: club de FIMCP dedicado a la mecánica '
     'automotriz.',
     '', True, '', 'sin_verificar'),
    ('AIChE ESPOL', 'Ingeniería',
     'Capítulo estudiantil del American Institute of Chemical Engineers en '
     'FCNM.',
     '', True, '', 'sin_verificar'),
    ('ACI ESPOL', 'Ingeniería',
     'Capítulo estudiantil del American Concrete Institute, especializado '
     'en cemento y concreto (FICT).',
     '', True, '', 'sin_verificar'),
    ('ASCE ESPOL', 'Ingeniería',
     'Capítulo estudiantil de la American Society of Civil Engineers en '
     'FICT.',
     '', True, '', 'sin_verificar'),
    ('IAHR ESPOL', 'Ingeniería',
     'Capítulo estudiantil de la International Association for '
     'Hydro-Environment Engineering and Research, enfocado en hidráulica y '
     'medioambiente (FICT).',
     '', True, '', 'sin_verificar'),
    ('Club Emprende', 'Negocios',
     'Club vinculado al Centro de Emprendimiento e Innovación (i3lab) que '
     'impulsa proyectos de emprendimiento estudiantil.',
     '', True, 'https://www.instagram.com/clubemprende.espol/', 'activo'),
    ('Suitcase Club', 'Negocios',
     'Club de la FCSH enfocado en gestión y producción de eventos.',
     '', True, 'https://www.instagram.com/suitcaseclub/', 'activo'),
    ('Tweening', 'Arte',
     'Club de FADCOM dedicado a ilustración, guion y animación.',
     '', True, '', 'sin_verificar'),
    ('Alucine', 'Arte',
     'Cineclub de FADCOM: proyecciones y análisis de cine.',
     '', True, '', 'sin_verificar'),
    ('D-PRO', 'Arte',
     'Club de FADCOM enfocado en diseño de producto.',
     '', True, '', 'sin_verificar'),
    ('Argumentum', 'Cultura',
     'Club de debate y oratoria de ESPOL, activo desde 2014.',
     '', True, '', 'sin_verificar'),
    ('ACP', 'Cultura',
     'Acción Cultural Politécnica: club dedicado a la música y las artes '
     'dentro de la comunidad politécnica.',
     '', True, '', 'sin_verificar'),
    ('FANPOL', 'Cultura',
     'Familia Anime Politécnica: comunidad dedicada a la cultura asiática '
     '(anime, manga, gastronomía y tradiciones de Japón, Corea y China).',
     '', True, '', 'activo'),
    ('Liga Deportiva Politécnica', 'Deportes',
     'Liga deportiva estudiantil de ESPOL que organiza torneos y '
     'actividades deportivas entre facultades.',
     '', True, '', 'activo'),
    ('BIOSOC ESPOL', 'Ciencias',
     'Biological Society ESPOL: grupo estudiantil de biología (FCV), avalado '
     'por la Royal Society, con salidas de campo, ferias científicas y '
     'proyectos de conservación (Yasuní, bosques secos).',
     'biosoc@espol.edu.ec', True, 'https://www.instagram.com/biosocespol/', 'poco_activo'),
    ('Kawsay', 'Cultura',
     'Comunidad de la FCV enfocada en sostenibilidad y reciclaje, organiza '
     'actividades como el concurso RECICRAWR junto a la Asociación '
     'Estudiantil de la facultad.',
     '', True, '', 'sin_verificar'),
    ('AUCE', 'Cultura',
     'Acción Universitaria: comunidad de liderazgo juvenil y acción '
     'solidaria de orientación católica, abierta a estudiantes de '
     'cualquier facultad.',
     '', True, '', 'sin_verificar'),
    # Cuenta de Instagram real pero sin publicar desde 2014: se marca inactivo
    # en vez de excluirlo, para no perder el registro de que existió.
    ('593 Guides Club', 'Negocios',
     'Club estudiantil de turismo y guianza de la FCSH. Su cuenta de '
     'Instagram lleva más de una década sin actividad.',
     '', False, 'https://www.instagram.com/593guidesclub/', 'inactivo'),
]

ESTUDIANTES = ['estudiante1', 'estudiante2']


class Command(BaseCommand):
    help = 'Carga categorias, comunidades y estudiantes de prueba'

    def handle(self, *args, **options):
        facultades = {
            sigla: Facultad.objects.get_or_create(
                nombre=sigla, defaults={'descripcion': descripcion}
            )[0]
            for sigla, descripcion in FACULTADES.items()
        }

        for nombre, categoria, descripcion, contacto, activa, instagram, nivel_actividad in COMUNIDADES:
            cat, _ = Categoria.objects.get_or_create(nombre=categoria)
            facultad = facultades.get(FACULTAD_POR_COMUNIDAD.get(nombre, ''))
            logo = LOGO_POR_COMUNIDAD.get(nombre, '')
            comunidad, creada = Comunidad.objects.get_or_create(
                nombre=nombre,
                defaults={
                    'descripcion': descripcion,
                    'categoria': cat,
                    'facultad': facultad,
                    'contacto': contacto,
                    'logo': logo,
                    'activa': activa,
                    'instagram': instagram,
                    'nivel_actividad': nivel_actividad,
                },
            )
            if not creada:
                # el comando es re-ejecutable: si la comunidad ya existia (p.ej.
                # se corrio antes de esta actualizacion), se refresca con los
                # datos verificados en vez de dejar la version vieja.
                comunidad.descripcion = descripcion
                comunidad.categoria = cat
                comunidad.facultad = facultad
                comunidad.contacto = contacto
                comunidad.logo = logo
                comunidad.activa = activa
                comunidad.instagram = instagram
                comunidad.nivel_actividad = nivel_actividad
                comunidad.save()

        for username in ESTUDIANTES:
            if not User.objects.filter(username=username).exists():
                User.objects.create_user(username=username, password='espol2026')

        con_logo = Comunidad.objects.exclude(logo='').count()
        self.stdout.write(self.style.SUCCESS(
            f'Listo: {Categoria.objects.count()} categorias, '
            f'{Facultad.objects.count()} facultades, '
            f'{Comunidad.objects.count()} comunidades ({con_logo} con logo), '
            f'{User.objects.count()} usuarios'
        ))
