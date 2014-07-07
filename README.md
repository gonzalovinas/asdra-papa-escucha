<html>
<head>
</head>

<img src="https://travis-ci.org/gonzalovinas/asdra-papa-escucha.svg?branch=master"/>
<br>

<h1>
Sistema Interno de Gestión de Entrevistas "Papá Escucha" de ASDRA
</h1>
<br>

Este sistema es un regalo que le he hecho a mi vecino Horacio Rigamonti (horacio@rigamonti.com.ar), quien trabaja con la gente de ASDRA y
al comentarme su necesidad de pasar de manejar una base de datos MS-ACCESS que se enviaban entre los padres
por correo electrónico surgio la idea de llevarlo a la Web, y se lo hice.

Puede encontrar los fuentes en el repositorio GitHub: https://github.com/gonzalovinas/asdra-papa-escucha
Puede ingresar al sitio de reporte de incidencias en: http://asdrapapaescucha.myjetbrains.com/

Para más información sobre ASDRA visitar http://asdra.org.ar/
<br>

<br>

<h3>RQs<h3>
<br>

<p><u>Alta Entrevistas</u></p>
<br>
<br>

Los campos de edición arrancan desde la mitad de la pantalla. ???
Los campos obligatorios deben ser lo mínimo indispensable. Muchas veces damos de alta entrevistas con casi nada de información y completamos después.
En la lista debe aparacer dos columnas para papá y mamá escucha una vez que fue asigada la entrevista.
debe aparecer en blanco hasta tanto uno de nosotros no ponemos ahi.
Hay campos que no es necesario que aparezcan en la lista: edades, ocupaciones, etc.
Deben verse las dos fechas iniciales,  Ciudad, barrio donde viven la mamá y el papá ( habrá que crear los campos que no estaban considerados)
La búsqueda debe ser por cualquier campo.

Te mando el formulario y los campos en formato Excel.

Fecha de llamada.  Por defecto = fecha del sistema
Fecha entrevista >= fecha llamada
Status debe ser un campo con 5 o 6 opciones (ejm.: pendiente, realizada, suspendida, etc )
Mamá y Papá escucha deben ser dos maestros para ingresar los papás que están disponibles
Los demás campos, rangos numéricos y formatos se que vos los vas a deducir.
<br>

<p><u>Los comandos</u></p>
<br>

<ul>
<li>Filtrar por Status</li>
<li>Nueva entrevista</li>
<li>Buscar entrevista</li>
<li>Siguiente</li>
<li>Anterior</li>
<li>Última entrevista</li>
<li>Filtrar (por fecha, papá escucha, mamá escucha, etc)</li>
<li>Eliminar entrevista</li>
<li>Imprimir formulario</li>
<li>Si no fuera complicado: enviar entrevista por mail</li>
</ul>
</html>
