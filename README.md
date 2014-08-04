<html>
<head>
</head>

<img src="https://travis-ci.org/gonzalovinas/asdra-papa-escucha.svg?branch=master"/>
<br>

<h1>
Sistema Interno de Gestión de Entrevistas "Papá Escucha" de ASDRA
</h1>
<br>

<h3>Historia<h3>

Este sistema es un regalo que le he hecho a mi vecino Horacio Rigamonti (horacio@rigamonti.com.ar), quien trabaja con la gente de ASDRA y
al comentarme su necesidad de pasar de manejar una base de datos MS-ACCESS que se enviaban entre los padres
por correo electrónico surgio la idea de llevarlo a la Web, y se lo hice.

Puede encontrar los fuentes en el repositorio GitHub: https://github.com/gonzalovinas/asdra-papa-escucha
Puede ingresar al sitio de reporte de incidencias en: http://youtrack.myzeta.tk/issues/PAPE

Para más información sobre ASDRA visitar http://asdra.org.ar/
<br>



<h2>Ubuntu (14.x Thar) Deploy</h2>
<ul>
<li>apache2</li>
<li>sqlite3</li>
<li>git-core</li>
<li>postfix</li>
<li>v8 javascript engine (it's ok to install nodejs for example...)</li>
</ul>
<ul>
<li>ruby 1.9.1</li>
<li>default-jdk</li>
<li>default-jre (remember to set JAVA_HOME environment variable (ex: export JAVA_HOME=/usr/lib/jvm/java-7-openjdk-i386)</li>
<li>bundler</li>
<li>libxml2-dev  (nokogiri gem)</li>
<li>libxslt1-dev (nokogiri gem)</li>
<li>libsqlite3-dev</li>
</ul>
<ul>
<li>passenger</li>
</ul>
<ul>
<li>bundle install</li>
</ul>
</html>
