# Configurar Topotresc para aplicaciones moviles y de escritorio

Es posible configurar Topotres como fuente de mapas de muchas aplicaciones móviles y de escritorio que permitan fuentes online (TMS).

Instrucciones para configurar Topotres en:

- [Oruxmaps](#Oruxmaps) ( Android )
- [Gurumaps](#Gurumaps) ( IOS: Iphone, IPAD... )
- [OsmAnd](#OsmAnd) ( Android / IOS: Iphone, IPAD... )
- [MapPlus](#MapPlus) ( Android / IOS: Iphone, IPAD... )
- [QMapShack](#QMapShack)  ( Windows / Mac / Linux )
- [MOBAC, SASPlanet, QGIS](#MOBAC-SASPlanet-QGIS) ( Windows / Mac / Linux )
- [TwoNav Land](#TwoNav-Land) ( Windows / Mac )

En general es posible configurar cualquier aplicación que adminta fuentes de mapa online TMS ajustando en la configuración la siguiene URL: ```https://api.topotresc.com/tiles/{z}/{x}/{y}.png```

## QMapShack
Descargar el archivo TMS y copiarlo en la carpeta de mapas de QMapShack: [https://www.topotresc.com/docs/topotresc_cat_piri.tms](https://www.topotresc.com/docs/topotresc_cat_piri.tms)

Mas detalles en https://github.com/Maproom/qmapshack/wiki/DocQuickStartSpanish  *Configurar carpetas de mapas*


## Gurumaps
Cargar en la aplicación el siguiente archivo XML: [https://www.topotresc.com/docs/topotresc_cat_piri.xml](https://www.topotresc.com/docs/topotresc_cat_piri.xml)

Para enviar o cargar el archivo en la aplicación tenemos varias opciones.
- Al descargar cuando pregunta que hacer con el archivo seleccionar: "enviar a" y seleccionar Gurumaps.
- Enviarnos el archivo por correo a nosotros mismos, abrir el adjunto desde el móvil y seleccionar "enviar a" Gurumaps.

## Oruxmaps
Copiar el siguiente archivo: [https://www.topotresc.com/docs/onlinemapsources.xml](https://www.topotresc.com/docs/onlinemapsources.xml) en la carpeta del móvil:

```Almacenamiento interno compartido\oruxmaps\mapfiles\customonlinemaps\```

En caso de que ya tengas el archivo XML con otros mapas, editarlo y insertar esto justo antes de la ultima linea:
```
<onlinemapsource uid="701">
<name>Topotresc (PIRI)</name>
<url><![CDATA[https://api.topotresc.com/tiles/{$z}/{$x}/{$y}.png]]></url>
<website><![CDATA[<a href="https://www.topotresc.com</a>]]></website>
<minzoom>7</minzoom>
<maxzoom>17</maxzoom>
<projection>MERCATORESFERICA</projection>
<servers></servers>
<httpparam name="User-Agent">{om}</httpparam>
<cacheable>1</cacheable>
<downloadable>1</downloadable>
<maxtilesday>0</maxtilesday>
<maxthreads>0</maxthreads>
```

## OsmAnd
Cargar en la aplicación el siguiente archivo XML: [https://www.topotresc.com/docs/topotresc_cat_piri.xml](https://www.topotresc.com/docs/topotresc_cat_piri.xml)
En ios (iphone) para enviar o cargar el archivo en la aplicación tenemos varias opciones.
- Al descargar cuando pregunta que hacer con el archivo seleccionar: "enviar a" y seleccionar OsmAnd.
- Enviarnos el archivo por correo a nosotros mismos, abrir el adjunto desde el móvil y seleccionar "enviar a" OsmAnd.

## MapPlus
Cargar en la aplicación el siguiente archivo XML: [https://www.topotresc.com/docs/topotresc_cat_piri.xml](https://www.topotresc.com/docs/topotresc_cat_piri.xml)
En ios (iphone) para enviar o cargar el archivo en la aplicación tenemos varias opciones.
- Al descargar cuando pregunta que hacer con el archivo seleccionar: "enviar a" y seleccionar MapPlus.
- Enviarnos el archivo por correo a nosotros mismos, abrir el adjunto desde el móvil y seleccionar "enviar a" MapPlus.


## MOBAC SASPlanet QGIS
Ajustar o añadir en la respectiva configuración de mapas online la siguiente URL: ```https://api.topotresc.com/tiles/{z}/{x}/{y}```

## TwoNav Land
Cargar el siguiente archivo de configuración: [https://www.topotresc.com/docs/Topotresc.cosm](https://www.topotresc.com/docs/Topotresc.cosm) 
