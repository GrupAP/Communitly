import os

from django.contrib.auth.models import User
from django.core.management.base import BaseCommand

from comunidades.models import Categoria, Comunidad, Facultad, PublicacionInstagram

# En local (sin definir la variable) sigue siendo 'espol2026' como siempre;
# en un despliegue real conviene fijar DJANGO_SEED_PASSWORD a algo propio,
# porque este archivo (y por lo tanto la contrasena por defecto) es publico.
CLAVE_SEMILLA = os.environ.get('DJANGO_SEED_PASSWORD', 'espol2026')

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
    # Estos 9 no tenian logo propio: se uso la foto de perfil publica de su
    # cuenta de Instagram (misma fuente que instagram/nivel_actividad).
    'ACI ESPOL': 'aci.jpg',
    'AIChE ESPOL': 'aiche.jpg',
    'ASHRAE ESPOL': 'ashrae.jpg',
    'Alucine': 'alucine.jpg',
    'IAHR ESPOL': 'iahr.jpg',
    'Kawsay': 'kawsay.jpg',
    'Liga Deportiva Politécnica': 'ldp.jpg',
    'MatEs': 'mates.jpg',
    'RAS ESPOL': 'ras.jpg',
    'D-PRO': 'dpro.jpg',
}

# nombre de la comunidad -> ficha informativa (carrera, fundado,
# lugar_reuniones, membresia). Solo se listan los clubes cuyos gestores ya
# confirmaron estos datos (ver clubes_info.md en la raiz del repo); el resto
# queda sin ficha en vez de inventar un valor. El campo "reuniones" (dia/hora)
# se deja fuera a proposito: se decidio que no aporta valor en el catalogo.
FICHA_POR_COMUNIDAD = {
    'CIAP': {
        'carrera': 'Computación y Ciencias de Datos (membresía libre, no exclusiva)',
        'lugar_reuniones': 'FIEC 11D',
        'membresia': 'Abierta / libre',
    },
    'TAWS': {
        'carrera': 'Computación, Logística y Transporte, Administración de Empresas',
        'fundado': '2007',
        'lugar_reuniones': 'FIEC 11C',
        'membresia': 'Ninguna',
    },
    'NIoT': {
        'carrera': 'Carreras de FIEC (libre, no exclusiva)',
        'lugar_reuniones': 'FIEC 11D',
        'membresia': 'Ninguna',
    },
    'KOKOA': {
        'carrera': 'Computación, Electrónica y otras carreras de FIEC (libre, no exclusiva)',
        'lugar_reuniones': 'FIEC 11D',
        'membresia': 'Ninguna',
    },
    'PHYCOM': {
        'carrera': 'Libre / no exclusiva (Physical Computing)',
        'membresia': 'Abierta a estudiantes, curiosos, inventores y soñadores; no se requiere experiencia previa',
    },
    'IEEE ESPOL Student Branch': {
        'membresia': (
            'Abierta — 3 categorías (estudiantil, profesional, asociativo); '
            'requiere cumplir criterios académicos/profesionales y aceptar el código de ética'
        ),
    },
    # Bio de Instagram y linktr.ee/mecatronica_espol (sep-2026) no dan carrera,
    # fundacion ni lugar de reuniones, asi que esos campos quedan sin dato en
    # vez de inventarlos; solo se confirma que existe un formulario de
    # aspirantes ("BIENVENIDOS ASPIRANTES" en su Linktree).
    'Club de Mecatrónica ESPOL': {
        'membresia': 'Abierta — se postula mediante un formulario para aspirantes',
    },
    # Bio e historias destacadas ("Requisitos") de Instagram y su sitio
    # (argumentum.oe.espol.edu.ec), sep-2026. No indican un lugar de
    # reuniones fijo, asi que ese campo queda sin dato.
    'Argumentum': {
        'carrera': 'Libre / no exclusiva (abierto a cualquier estudiante de ESPOL)',
        'fundado': '2014',
        'membresia': (
            'Abierta — solo se requiere ser estudiante de ESPOL e inscribirse '
            'al proceso de ingreso; no se necesitan conocimientos previos'
        ),
    },
    # Bio e historias destacadas de Instagram (sep-2026): no dan fecha de
    # fundacion, lugar de reuniones ni requisitos de membresia, asi que esos
    # campos quedan sin dato en vez de inventarlos.
    'D.A.T.A Club': {
        'carrera': 'Estadística',
    },
    # Bio (ubicacion) y linktr.ee/club_acp_espol (sep-2026): sin fecha de
    # fundacion publica, asi que ese campo queda sin dato.
    'ACP': {
        'carrera': 'Libre / no exclusiva (arte, música, danza, fotografía, audiovisual)',
        'lugar_reuniones': 'Biblioteca Central de ESPOL',
        'membresia': (
            'Abierta — se postula por área (Diseño Gráfico, Producción '
            'Audiovisual, Fotografía) o de forma general ("¡Únete al Club!")'
        ),
    },
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
    # Ultima publicacion visible es de dic-2025 (~9 meses antes de esta
    # verificacion), aunque el resto del perfil se ve bien mantenido.
    ('RAS ESPOL', 'Tecnología',
     'Robotics & Automation Society: capítulo técnico de IEEE ESPOL '
     'enfocado en robótica y automatización, distinto del club Robota.',
     '', True, 'https://www.instagram.com/ras_espol/', 'poco_activo'),
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
     'estadística aplicada y análisis de datos; organiza mega ayudantías y '
     'promueve la carrera de Estadística en ferias y eventos de ESPOL.',
     '', True, 'https://www.instagram.com/dataclubec/', 'activo'),
    ('MatEs', 'Ciencias',
     'Club de la FCNM dedicado a la divulgación y competencias de '
     'matemáticas.',
     '', True, 'https://www.instagram.com/mates_espol/', 'activo'),
    ('AAPG ESPOL', 'Ciencias',
     'Capítulo estudiantil de la American Association of Petroleum '
     'Geologists, enfocado en geología del petróleo (FICT).',
     '', True, 'https://www.instagram.com/aapgespol/', 'activo'),
    ('Yaku Club de Buceo Investigativo', 'Ciencias',
     'Club de buceo científico que forma a estudiantes en ciencias marinas '
     'y certificación de buceo (CMAS/FEDASUB).',
     '', True, 'https://www.instagram.com/yakubuceo_espol/', 'activo'),
    ('ASME ESPOL', 'Ingeniería',
     'Capítulo estudiantil de la American Society of Mechanical Engineers '
     'en FIMCP.',
     '', True, 'https://www.instagram.com/asme_espol/', 'activo'),
    ('ASHRAE ESPOL', 'Ingeniería',
     'Capítulo estudiantil ASHRAE de FIMCP enfocado en calefacción, '
     'ventilación, refrigeración y aire acondicionado.',
     '', True, 'https://www.instagram.com/ashrae_espol/', 'activo'),
    ('MAEC', 'Ingeniería',
     'Mecánica Automotriz ESPOL Club: club de FIMCP dedicado a la mecánica '
     'automotriz.',
     '', True, '', 'sin_verificar'),
    ('AIChE ESPOL', 'Ingeniería',
     'Capítulo estudiantil del American Institute of Chemical Engineers en '
     'FCNM.',
     '', True, 'https://www.instagram.com/aiche.espol/', 'activo'),
    ('ACI ESPOL', 'Ingeniería',
     'Capítulo estudiantil del American Concrete Institute, especializado '
     'en cemento y concreto (FICT).',
     '', True, 'https://www.instagram.com/aci_espol/', 'activo'),
    # Ultima publicacion visible es de oct-2025 (~11 meses antes que las demas
    # verificaciones de esta tanda, que tienen posts de 2026): poco activo.
    ('ASCE ESPOL', 'Ingeniería',
     'Capítulo estudiantil de la American Society of Civil Engineers en '
     'FICT.',
     '', True, 'https://www.instagram.com/asce.espol/', 'poco_activo'),
    ('IAHR ESPOL', 'Ingeniería',
     'Capítulo estudiantil de la International Association for '
     'Hydro-Environment Engineering and Research, enfocado en hidráulica y '
     'medioambiente (FICT).',
     '', True, 'https://www.instagram.com/iahrespol/', 'activo'),
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
     '', True, 'https://www.instagram.com/alucineclub/', 'poco_activo'),
    ('D-PRO', 'Arte',
     'Club de FADCOM enfocado en diseño de producto.',
     '', True, 'https://www.instagram.com/clubdpro/', 'activo'),
    ('Argumentum', 'Cultura',
     'Club de debate y oratoria de la ESPOL, activo desde el 1 de agosto de '
     '2014; organiza torneos internos, ligas, conversatorios académicos y '
     'recibe aspirantes sin requerir experiencia previa.',
     '', True, 'https://www.instagram.com/argumentumespol/', 'activo'),
    ('ACP', 'Cultura',
     'Acción Cultural Politécnica: espacio artístico y cultural de la ESPOL '
     'con áreas de música, baile, fotografía, diseño gráfico y producción '
     'audiovisual; formación, producción y difusión del arte dentro de la '
     'comunidad politécnica.',
     '', True, 'https://www.instagram.com/acpclub.espol/', 'activo'),
    ('FANPOL', 'Cultura',
     'Familia Anime Politécnica: comunidad dedicada a la cultura asiática '
     '(anime, manga, gastronomía y tradiciones de Japón, Corea y China).',
     '', True, 'https://www.instagram.com/clubfanpol.espol/', 'activo'),
    ('Liga Deportiva Politécnica', 'Deportes',
     'Liga deportiva estudiantil de ESPOL que organiza torneos y '
     'actividades deportivas entre facultades.',
     '', True, 'https://www.instagram.com/ldp_espol/', 'activo'),
    ('BIOSOC ESPOL', 'Ciencias',
     'Biological Society ESPOL: grupo estudiantil de biología (FCV), avalado '
     'por la Royal Society, con salidas de campo, ferias científicas y '
     'proyectos de conservación (Yasuní, bosques secos).',
     'biosoc@espol.edu.ec', True, 'https://www.instagram.com/biosocespol/', 'poco_activo'),
    # Su Instagram no publica desde jul-2021 (~5 anios): se marca inactivo,
    # igual que se hizo con 593 Guides Club, pero se deja activa=True porque
    # no se confirmo que el club en si haya desaparecido (RECICRAWR se sigue
    # mencionando en notas de prensa de la facultad).
    ('Kawsay', 'Cultura',
     'Comunidad de la FCV enfocada en sostenibilidad y reciclaje, organiza '
     'actividades como el concurso RECICRAWR junto a la Asociación '
     'Estudiantil de la facultad.',
     '', True, 'https://www.instagram.com/clubkawsay/', 'inactivo'),
    ('AUCE', 'Cultura',
     'Acción Universitaria: comunidad de liderazgo juvenil y acción '
     'solidaria de orientación católica, abierta a estudiantes de '
     'cualquier facultad.',
     '', True, 'https://www.instagram.com/accionistaespol/', 'activo'),
]

# nombre de la comunidad -> sus 3 publicaciones mas recientes en Instagram
# (visitadas manualmente en sep-2026; ver PublicacionInstagram). Solo se
# listan los clubes con cuenta de Instagram verificada en COMUNIDADES; el
# resto queda sin carrusel de actividad reciente en vez de inventar posts.
# Algunas urls pertenecen a otra cuenta (colaboracion/publicacion compartida)
# porque ese post aparece igual en el feed propio del club.
#
# 'imagen' es un archivo en backend/media/actividades/ (captura propia del
# post, recortada a mano). Se deja en '' a proposito quando el post central
# es el "spotlight" de una persona (cara + nombre completo como protagonista,
# ej. un anuncio de speaker): no se reutiliza esa foto para no re-alojar el
# retrato de un tercero que no dio su consentimiento para esta app. En esos
# casos el frontend cae al embed en vivo de Instagram en vez de la imagen.
PUBLICACIONES_POR_COMUNIDAD = {
    'CIAP': [
        {'url': 'https://www.instagram.com/ciap_espol/p/DdDIW6eICVC/',
         'titulo': 'Participación en la Ruta de la Innovación 2026', 'imagen': 'DdDIW6eICVC.jpg'},
        {'url': 'https://www.instagram.com/ciap_espol/p/DdAiFXLoDc2/',
         'titulo': 'Delegación en el AWS Community Day Ecuador 2026', 'imagen': 'DdAiFXLoDc2.jpg'},
        {'url': 'https://www.instagram.com/ciap_espol/p/Dc6JajjoGQd/',
         'titulo': 'Speaker oficial en el AWS Community Day Ecuador 2026', 'imagen': ''},
    ],
    'TAWS': [
        {'url': 'https://www.instagram.com/taws_espol/p/DchH2OdFvom/',
         'titulo': 'Mega Ayudantía de Fundamentos de Programación', 'imagen': ''},
        {'url': 'https://www.instagram.com/taws_espol/p/DceZ-25FnDQ/',
         'titulo': 'Taller de Team Building con i3lab', 'imagen': 'DceZ-25FnDQ.jpg'},
        {'url': 'https://www.instagram.com/taws_espol/p/DccK0ivFpy-/',
         'titulo': 'Investigación aceptada en el ICEDEG 2026 (Lisboa)', 'imagen': ''},
    ],
    'NIoT': [
        {'url': 'https://www.instagram.com/club.niot.espol/reel/DdMx1dWv1e9/',
         'titulo': 'Recap de actividades del club', 'imagen': 'DdMx1dWv1e9.jpg'},
        {'url': 'https://www.instagram.com/club.niot.espol/p/DcSpLdOFarf/',
         'titulo': 'Mega Ayudantías para el 2do parcial', 'imagen': 'DcSpLdOFarf.jpg'},
        {'url': 'https://www.instagram.com/club.niot.espol/p/DcRj0dbH62h/',
         'titulo': 'Presentes en Clubes: Ready. Set. Join! 2026', 'imagen': 'DcRj0dbH62h.jpg'},
    ],
    'KOKOA': [
        {'url': 'https://www.instagram.com/kokoa_espol/p/Dc6nBGmz9Ow/',
         'titulo': 'Feria de Proyectos KOKOA', 'imagen': 'Dc6nBGmz9Ow.jpg'},
        {'url': 'https://www.instagram.com/kokoa_espol/p/DcU2dCEkXtX/',
         'titulo': 'Mega Ayudantía de Fundamentos de Programación', 'imagen': ''},
        {'url': 'https://www.instagram.com/kokoa_espol/p/DcGszzbEfo3/',
         'titulo': 'Lightning Talk: robot R.O.B.E.R.T.', 'imagen': ''},
    ],
    'PHYCOM': [
        {'url': 'https://www.instagram.com/phycom_espol/p/DcH_HWolm-i/',
         'titulo': 'Miembros como speakers en FLISoL', 'imagen': 'DcH_HWolm-i.jpg'},
        {'url': 'https://www.instagram.com/phycom_espol/p/DcHyWftmqEg/',
         'titulo': 'PHYCOM presente en FLISoL', 'imagen': 'DcHyWftmqEg.jpg'},
        {'url': 'https://www.instagram.com/phycom_espol/p/DbzIJ1Tmgq_/',
         'titulo': 'PHYCOM en Build with AI (GDG Guayaquil)', 'imagen': 'DbzIJ1Tmgq_.jpg'},
    ],
    'ROBOTA': [
        {'url': 'https://www.instagram.com/ciace_espol/p/DdMjQrXEW0V/',
         'titulo': 'Construcción del avión para el concurso de aviónica', 'imagen': 'DdMjQrXEW0V.jpg'},
        {'url': 'https://www.instagram.com/retodelpacifico_/p/DdFmAyWxczV/',
         'titulo': 'Reto del Pacífico – Robot Games, 3ra edición', 'imagen': 'DdFmAyWxczV.jpg'},
        {'url': 'https://www.instagram.com/rgzlecuador/p/Dc_qqtbpxlT/',
         'titulo': 'Campeones en Robot Games Zero Latitud', 'imagen': 'Dc_qqtbpxlT.jpg'},
    ],
    'IEEE ESPOL Student Branch': [
        {'url': 'https://www.instagram.com/ieee.espol.ias/p/DdRjPhklLHK/',
         'titulo': 'IEEE Rising Stars 2026 en Quito', 'imagen': 'DdRjPhklLHK.jpg'},
        {'url': 'https://www.instagram.com/ieee.espol/reel/DdRMadljJ69/',
         'titulo': 'Recap del IEEE Rising Stars LAC', 'imagen': 'DdRMadljJ69.jpg'},
        {'url': 'https://www.instagram.com/ieee.espol/p/DdOzKaADk9p/',
         'titulo': '24.º aniversario de IEEE ESPOL', 'imagen': 'DdOzKaADk9p.jpg'},
    ],
    'GISSC': [
        {'url': 'https://www.instagram.com/gissc_espol/p/DcATdx-DNdR/',
         'titulo': 'Participación en el Space Hack for Sustainability', 'imagen': 'DcATdx-DNdR.jpg'},
        {'url': 'https://www.instagram.com/gissc_espol/p/DcAQSFWjBBY/',
         'titulo': 'Pasantía de investigación en la ÉTS, Canadá', 'imagen': ''},
        {'url': 'https://www.instagram.com/gissc_espol/p/DcAOaekjBaz/',
         'titulo': 'Charla: SIG y teledetección en la Amazonía', 'imagen': 'DcAOaekjBaz.jpg'},
    ],
    'CIMAT': [
        {'url': 'https://www.instagram.com/espolfimcp/p/DcRCGMqESpp/',
         'titulo': 'Charla Materiales Conecta: control de corrosión', 'imagen': 'DcRCGMqESpp.jpg'},
        {'url': 'https://www.instagram.com/espolfimcp/reel/DcPCcqoSZEE/',
         'titulo': 'Materiales Conecta: preparación de superficies', 'imagen': 'DcPCcqoSZEE.jpg'},
        {'url': 'https://www.instagram.com/espolfimcp/p/DcL0hkAR5O5/',
         'titulo': 'Nueva edición de Materiales Conecta', 'imagen': 'DcL0hkAR5O5.jpg'},
    ],
    'IFT ESPOL': [
        {'url': 'https://www.instagram.com/capitan_geminis/p/DcjuoGhFp3W/',
         'titulo': 'Taller de dibujo "Garabatos" junto a IFT', 'imagen': 'DcjuoGhFp3W.jpg'},
        {'url': 'https://www.instagram.com/capitan_geminis/p/DceqBNFggvh/',
         'titulo': 'Taller Garabatos: monstruos y manchas', 'imagen': 'DceqBNFggvh.jpg'},
        {'url': 'https://www.instagram.com/ift_espol/p/Db_-bSVtWjn/',
         'titulo': 'Cine IFT: tarde de película', 'imagen': 'Db_-bSVtWjn.jpg'},
    ],
    'Politécnicas en STEAM': [
        {'url': 'https://www.instagram.com/politecnicas.steam/p/DRlZbFBEfMb/',
         'titulo': 'Conversatorio: Mujeres STEAM frente a la Violencia', 'imagen': ''},
        {'url': 'https://www.instagram.com/argumentumespol/p/DRdnZXSDEx_/',
         'titulo': 'Conversatorio por el 25N junto a Argumentum', 'imagen': ''},
        {'url': 'https://www.instagram.com/steam.space.girls/p/DDbSqjYsHG1/',
         'titulo': 'Conversatorio virtual: Perspectivas STEAM', 'imagen': 'DDbSqjYsHG1.jpg'},
    ],
    'IISE ESPOL': [
        {'url': 'https://www.instagram.com/espolfimcp/p/DdUJmGvFDA2/',
         'titulo': 'IISE Day: conectando la academia con la industria', 'imagen': 'DdUJmGvFDA2.jpg'},
        {'url': 'https://www.instagram.com/iise_espol/p/DdDQ4sNxngm/',
         'titulo': 'Celebración del ISE Day 2026', 'imagen': 'DdDQ4sNxngm.jpg'},
        {'url': 'https://www.instagram.com/iise_espol/p/DcmxBenxyTY/',
         'titulo': 'Visita técnica a CEDAL', 'imagen': 'DcmxBenxyTY.jpg'},
    ],
    'SPE ESPOL': [
        {'url': 'https://www.instagram.com/espolspe/p/DcLwAHwuL66/',
         'titulo': 'Visita técnica al Oriente ecuatoriano', 'imagen': 'DcLwAHwuL66.jpg'},
        {'url': 'https://www.instagram.com/espolspe/p/DblwKvXvqYb/',
         'titulo': 'Reclutamiento para PetroTest 2026', 'imagen': 'DblwKvXvqYb.jpg'},
        {'url': 'https://www.instagram.com/espolspe/p/Da0efV0OZ1Y/',
         'titulo': 'Webinar de bombas industriales', 'imagen': ''},
    ],
    'SME ESPOL': [
        {'url': 'https://www.instagram.com/smeespol/p/DdUsZlqRKkl/',
         'titulo': 'ECUAMINING 2026: nuevo auspiciante oficial', 'imagen': 'DdUsZlqRKkl.jpg'},
        {'url': 'https://www.instagram.com/fictespol/reel/Dc_t618tdWe/',
         'titulo': 'Día del Trabajador Minero Ecuatoriano', 'imagen': 'Dc_t618tdWe.jpg'},
        {'url': 'https://www.instagram.com/smeespol/p/DcybV7pEZ70/',
         'titulo': 'ECUAMINING 2026, 8.ª edición', 'imagen': 'DcybV7pEZ70.jpg'},
    ],
    'CADIEC': [
        {'url': 'https://www.instagram.com/cadiecespol/reel/DbbMlhkR6qP/',
         'titulo': 'Mercadito de las Fiestas Julianas', 'imagen': ''},
        {'url': 'https://www.instagram.com/cadiecespol/reel/DakrwX7xk_h/',
         'titulo': 'Artículo sobre remesas y economía ecuatoriana', 'imagen': ''},
        {'url': 'https://www.instagram.com/cadiecespol/p/DaiOk4tjquE/',
         'titulo': 'Inducción de aspirantes a CADIEC', 'imagen': 'DaiOk4tjquE.jpg'},
    ],
    'CLIP': [
        {'url': 'https://www.instagram.com/clip_espol/p/DccWMOGDLAB/',
         'titulo': 'Presentes en la Feria de Ciencias (FCNM)', 'imagen': 'DccWMOGDLAB.jpg'},
        {'url': 'https://www.instagram.com/clip_espol/p/DcCvXRuDJ9I/',
         'titulo': 'Charla-taller de Algoritmos de Optimización para IA', 'imagen': 'DcCvXRuDJ9I.jpg'},
        {'url': 'https://www.instagram.com/ieeecis.espol/p/DbDrhy5uo6C/',
         'titulo': 'Introducción a los Algoritmos de Optimización para IA', 'imagen': ''},
    ],
    'BREIK': [
        {'url': 'https://www.instagram.com/breikgye/p/DdC2ju5mk6V/',
         'titulo': 'PyWeekend: reto de programación', 'imagen': 'DdC2ju5mk6V.jpg'},
        {'url': 'https://www.instagram.com/breikgye/p/DcP2RfYAIJp/',
         'titulo': 'Día Mundial de la Fotografía', 'imagen': 'DcP2RfYAIJp.jpg'},
        {'url': 'https://www.instagram.com/breikgye/reel/DcOpPM3Rk2A/',
         'titulo': 'Coworking de clubes en FADCOM', 'imagen': 'DcOpPM3Rk2A.jpg'},
    ],
    'Club de Arqueología': [
        {'url': 'https://www.instagram.com/clubarqueologia.espol/p/DczO0RzGDqi/',
         'titulo': 'Finalistas en el 5min Pitch de la FCSH', 'imagen': 'DczO0RzGDqi.jpg'},
        {'url': 'https://www.instagram.com/clubarqueologia.espol/p/Da1ng87Den7/',
         'titulo': 'Conferencia: la cerámica bajo la mirada de un geólogo', 'imagen': 'Da1ng87Den7.jpg'},
        {'url': 'https://www.instagram.com/clubarqueologia.espol/p/DanfgYCxS2k/',
         'titulo': 'Charla sobre cerámica y geología', 'imagen': ''},
    ],
    'Club de Mecatrónica ESPOL': [
        {'url': 'https://www.instagram.com/codes_espol/p/Dcjw29-mmz3/',
         'titulo': 'Taller "Hackeando el Mundo Físico" (parte 2)', 'imagen': 'Dcjw29-mmz3.jpg'},
        {'url': 'https://www.instagram.com/codes_espol/p/Db8QFRwOdJx/',
         'titulo': 'Taller "Hackeando el Mundo Físico" con Club CODES', 'imagen': 'Db8QFRwOdJx.jpg'},
        {'url': 'https://www.instagram.com/club_mecatronica_espol/p/Db4Se7eESOf/',
         'titulo': 'Primer taller hands-on de impresión 3D', 'imagen': 'Db4Se7eESOf.jpg'},
    ],
    'ACP': [
        {'url': 'https://www.instagram.com/acpclub.espol/p/DdSr2UMDB9R/',
         'titulo': 'Project Dance Hall: ritmos caribeños', 'imagen': 'DdSr2UMDB9R.jpg'},
        {'url': 'https://www.instagram.com/acpclub.espol/p/DcyvGe5Fp87/',
         'titulo': 'Convocatoria: área de Producción Audiovisual', 'imagen': 'DcyvGe5Fp87.jpg'},
        {'url': 'https://www.instagram.com/acpclub.espol/p/DcyunonljNC/',
         'titulo': 'Convocatoria: área de Diseñadores Gráficos', 'imagen': 'DcyunonljNC.jpg'},
    ],
    'D.A.T.A Club': [
        {'url': 'https://www.instagram.com/dataclubec/p/Dc4aHeLBNFC/',
         'titulo': 'Mega Ayudantía de Fundamentos de Programación', 'imagen': ''},
        {'url': 'https://www.instagram.com/dataclubec/p/DcMaxslBmec/',
         'titulo': 'Mega Ayudantía de Cálculo de una Variable', 'imagen': ''},
        {'url': 'https://www.instagram.com/dataclubec/p/DcKn-nBDVI3/',
         'titulo': 'Segundo lugar en la Feria de Ciencias con el proyecto KAIRO', 'imagen': ''},
    ],
    'Argumentum': [
        {'url': 'https://www.instagram.com/argumentumespol/p/DTagph5EXIK/',
         'titulo': 'Sesión de fotos profesional para CV', 'imagen': 'DTagph5EXIK.jpg'},
        {'url': 'https://www.instagram.com/argumentumespol/p/DTJjbksEQKf/',
         'titulo': 'Recepción de nuevos miembros: Torneo de Aspirantes', 'imagen': 'DTJjbksEQKf.jpg'},
        {'url': 'https://www.instagram.com/argumentumespol/reel/DSaGztTEUVu/',
         'titulo': 'Rifa Cupido de Argumentum', 'imagen': ''},
    ],
    'Yaku Club de Buceo Investigativo': [
        {'url': 'https://www.instagram.com/cds_espol/p/C0nZdTEM-1v/',
         'titulo': 'Minga de limpieza en playa Engabao', 'imagen': 'C0nZdTEM-1v.jpg'},
        {'url': 'https://www.instagram.com/yakubuceo_espol/p/Cuk0snTMYPK/',
         'titulo': 'Calendario de fechas ambientales', 'imagen': 'Cuk0snTMYPK.jpg'},
        {'url': 'https://www.instagram.com/espol1/reel/CtO5Q2Cub5z/',
         'titulo': 'La importancia de cuidar los océanos', 'imagen': 'CtO5Q2Cub5z.jpg'},
    ],
    'Club Emprende': [
        {'url': 'https://www.instagram.com/clubemprende.espol/p/DdNyphulpIr/',
         'titulo': 'Día 2 del Startup Weekend', 'imagen': 'DdNyphulpIr.jpg'},
        {'url': 'https://www.instagram.com/clubemprende.espol/p/DdLTgUCFu-C/',
         'titulo': 'Día 1 del Startup Weekend', 'imagen': 'DdLTgUCFu-C.jpg'},
        {'url': 'https://www.instagram.com/clubemprende.espol/p/DcPyPIyDSeZ/',
         'titulo': 'Presentes en el Ready Set Join', 'imagen': 'DcPyPIyDSeZ.jpg'},
    ],
    'Suitcase Club': [
        {'url': 'https://www.instagram.com/suitcaseclub/p/DYCs1Tqjl4I/',
         'titulo': 'Novatada PAO I 2026', 'imagen': 'DYCs1Tqjl4I.jpg'},
        {'url': 'https://www.instagram.com/suitcaseclub/p/DRn0asMDlk4/',
         'titulo': 'Taller de coctelería Mix&Chill', 'imagen': 'DRn0asMDlk4.jpg'},
        {'url': 'https://www.instagram.com/suitcaseclub/p/DQfrtGJDhND/',
         'titulo': 'Integración del club con espíritu Halloween', 'imagen': 'DQfrtGJDhND.jpg'},
    ],
    'BIOSOC ESPOL': [
        {'url': 'https://www.instagram.com/biosocespol/p/DBgtyg4xQKt/',
         'titulo': 'Charla sobre organizaciones académicas de la facultad', 'imagen': 'DBgtyg4xQKt.jpg'},
        {'url': 'https://www.instagram.com/biosocespol/p/DAwkAqjJls-/',
         'titulo': 'Concurso "Biología en Arte", I edición', 'imagen': 'DAwkAqjJls-.jpg'},
        {'url': 'https://www.instagram.com/biosocespol/p/DAbH6mYRTKc/',
         'titulo': 'Recap de actividades del semestre', 'imagen': 'DAbH6mYRTKc.jpg'},
    ],
    'D-PRO': [
        {'url': 'https://www.instagram.com/clubdpro/p/DbnvMiuO5Vj/',
         'titulo': 'Charla sobre el proceso creativo de BRUT Studio', 'imagen': ''},
    ],
    'ACI ESPOL': [
        {'url': 'https://www.instagram.com/aci_espol/p/DbdjKRggG3D/',
         'titulo': 'Charla de liderazgo estudiantil junto a ASCE ESPOL', 'imagen': ''},
        {'url': 'https://www.instagram.com/aci_espol/p/DdNjZGTgvX8/',
         'titulo': 'Demostración educativa de un filtro de agua', 'imagen': ''},
    ],
    'RAS ESPOL': [
        {'url': 'https://www.instagram.com/ras_espol/p/Dc6ONinNIkG/',
         'titulo': 'Charla del IEEE Control Systems Society sobre sistemas electrónicos',
         'imagen': ''},
        {'url': 'https://www.instagram.com/retodelpacifico_/p/DdFmAyWxczV/',
         'titulo': 'Promoción de la competencia de robótica Reto del Pacífico 2026',
         'imagen': ''},
    ],
    'MatEs': [
        {'url': 'https://www.instagram.com/mates_espol/p/DbUKEUUDwVu/',
         'titulo': 'Participación de estudiantes y docentes en la escuela EMALCA', 'imagen': ''},
        {'url': 'https://www.instagram.com/mates_espol/p/DYTGZE8EQgX/',
         'titulo': 'Conmemoración del Día Internacional de las Mujeres en la Matemática',
         'imagen': ''},
    ],
    'AAPG ESPOL': [
        {'url': 'https://www.instagram.com/aapgespol/p/DcY2vI2uqbk/',
         'titulo': "Calendario educativo \"Geonoredad del mes\" sobre sistemas petroleros",
         'imagen': ''},
        {'url': 'https://www.instagram.com/aapgespol/p/DbMNnv4D9UF/',
         'titulo': 'Calendario educativo de geología con sesiones de curso', 'imagen': ''},
    ],
    'ASME ESPOL': [
        {'url': 'https://www.instagram.com/asme_espol/p/DcEP53vRAoY/',
         'titulo': 'Taller de control de calidad y ensayos no destructivos en FIMCP',
         'imagen': ''},
        {'url': 'https://www.instagram.com/asme_espol/p/DbbHsD5Rn1n/',
         'titulo': 'Charla técnica sobre ingeniería de sistemas de bombeo', 'imagen': ''},
    ],
    'ASHRAE ESPOL': [
        {'url': 'https://www.instagram.com/ashrae_espol/p/DbwCgdXBLDa/',
         'titulo': 'Contenido educativo sobre sistemas de climatización (HVAC)', 'imagen': ''},
        {'url': 'https://www.instagram.com/ashrae_espol/p/DZ5bfY-h6jF/',
         'titulo': 'Publicación técnica sobre aire acondicionado y termostatos', 'imagen': ''},
    ],
    'AIChE ESPOL': [
        {'url': 'https://www.instagram.com/aiche.espol/p/Dawj_UdlVe8/',
         'titulo': 'Difusión de cursos gratuitos y pagados de AIChE Academy', 'imagen': ''},
        {'url': 'https://www.instagram.com/aiche.espol/p/Dag_CwSFSZW/',
         'titulo': 'Curso de diseño de redes de agua potable con EPANET', 'imagen': ''},
    ],
    'ASCE ESPOL': [
        {'url': 'https://www.instagram.com/asce.espol/p/DbyvchrFAms/',
         'titulo': 'Visita técnica a "La Qondesa" con inscripción para socios y estudiantes',
         'imagen': ''},
        {'url': 'https://www.instagram.com/asce.espol/p/DboINehlGTa/',
         'titulo': 'Webinar gratuito sobre gestión de residuos para la ingeniería', 'imagen': ''},
    ],
    'IAHR ESPOL': [
        {'url': 'https://www.instagram.com/iahrespol/p/DZOqmpqPMBC/',
         'titulo': 'Visita técnica a Cuenca: laboratorios de potabilización de agua',
         'imagen': ''},
        {'url': 'https://www.instagram.com/iahrespol/p/DRSp4gVEr54/',
         'titulo': 'Visita a la planta de tratamiento de agua Atahualpa-Santa Elena',
         'imagen': ''},
    ],
    'Alucine': [
        {'url': 'https://www.instagram.com/alucineclub/p/DRzuX3LjST1/',
         'titulo': 'Concurso "Diciembre Alucinante" con suscripción de streaming de premio',
         'imagen': ''},
        {'url': 'https://www.instagram.com/alucineclub/p/DQj18i2DWZs/',
         'titulo': 'Función y análisis de la película Frankenweenie', 'imagen': ''},
    ],
    'FANPOL': [
        {'url': 'https://www.instagram.com/clubfanpol.espol/p/DdAnr8_ER9J/',
         'titulo': 'Participación en Expo Corea 2026 en Quito', 'imagen': ''},
        {'url': 'https://www.instagram.com/clubfanpol.espol/p/DcmQhvzGmmM/',
         'titulo': 'Festival de cine de Studio Ghibli en ESPOL', 'imagen': ''},
    ],
    'Liga Deportiva Politécnica': [
        {'url': 'https://www.instagram.com/espol.femeninofc/p/Dcmuv-UOedm/',
         'titulo': 'Anuncio de semifinal de fútbol femenino ESPOL', 'imagen': ''},
        {'url': 'https://www.instagram.com/espol.masculinofc/p/DcmuLFdxw39/',
         'titulo': 'Anuncio de cuartos de final de fútbol masculino ESPOL', 'imagen': ''},
    ],
    'AUCE': [
        {'url': 'https://www.instagram.com/accionistaespol/p/DbGv6xCBy0W/',
         'titulo': 'Espacio de lectura reflexiva "Latia Duvrina" en el cubículo del club',
         'imagen': ''},
        {'url': 'https://www.instagram.com/accionistaespol/p/Da11aVJRKbA/',
         'titulo': 'Invitación a rezar la Coronilla de la Divina Misericordia', 'imagen': ''},
    ],
}

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
            ficha = FICHA_POR_COMUNIDAD.get(nombre, {})
            carrera = ficha.get('carrera', '')
            fundado = ficha.get('fundado', '')
            lugar_reuniones = ficha.get('lugar_reuniones', '')
            membresia = ficha.get('membresia', '')
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
                    'carrera': carrera,
                    'fundado': fundado,
                    'lugar_reuniones': lugar_reuniones,
                    'membresia': membresia,
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
                comunidad.carrera = carrera
                comunidad.fundado = fundado
                comunidad.lugar_reuniones = lugar_reuniones
                comunidad.membresia = membresia
                comunidad.save()

            publicaciones = PUBLICACIONES_POR_COMUNIDAD.get(nombre, [])
            if publicaciones and not comunidad.publicaciones_instagram.exists():
                # solo se cargan si el club no tiene publicaciones propias
                # (p.ej. agregadas a mano desde el admin) para no duplicar.
                PublicacionInstagram.objects.bulk_create([
                    PublicacionInstagram(
                        comunidad=comunidad,
                        url=publicacion['url'],
                        titulo=publicacion['titulo'],
                        imagen=publicacion['imagen'],
                        orden=orden,
                    )
                    for orden, publicacion in enumerate(publicaciones)
                ])

        for username in ESTUDIANTES:
            if not User.objects.filter(username=username).exists():
                User.objects.create_user(username=username, password=CLAVE_SEMILLA)

        con_logo = Comunidad.objects.exclude(logo='').count()
        con_actividad = Comunidad.objects.filter(publicaciones_instagram__isnull=False).distinct().count()
        self.stdout.write(self.style.SUCCESS(
            f'Listo: {Categoria.objects.count()} categorias, '
            f'{Facultad.objects.count()} facultades, '
            f'{Comunidad.objects.count()} comunidades ({con_logo} con logo, '
            f'{con_actividad} con actividad reciente), '
            f'{User.objects.count()} usuarios'
        ))
