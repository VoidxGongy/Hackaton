# Suthon

Aplicación Flutter móvil de demostración para flujos de Supervisor y Coordinador de servicios de aseo.

## Ver la vista previa

En VS Code, abre **Run and Debug** y selecciona **Suthon — vista previa móvil**. La configuración prepara e inicia la interfaz en un marco de hasta 430 px de ancho usando el destino Linux; no es una página web.

También se puede ejecutar desde la raíz del proyecto:

Usa `bash tool/prepare_linux_preview.sh` para preparar las dependencias de la vista previa y luego `flutter run -d linux`. El proyecto no depende de plugins nativos de almacenamiento seguro en Linux, así que el arranque no requiere instalar `libsecret`.

## Alcance y cobertura de requisitos

La demo usa centros y personas ficticios con coordenadas de referencia de Barranquilla. Las coordenadas se centralizan en `DemoCoordinates` y son ajustables para el sitio de presentación. Los cambios de visitas, checklist y novedades se guardan localmente con Hive; la sincronización usa un servidor falso idempotente para demostrar la cola, no una API desplegada.

| Requisito | Estado actual |
|---|---|
| RF-01, RF-02 | Login y cierre de sesión demo; las pantallas se separan por rol. |
| RF-03, RF-04 | El coordinador puede crear supervisores y asignar visitas con centro, agenda y prioridad. |
| RF-05 | El supervisor ve sus visitas asignadas y sus centros, agenda, prioridad y checklist. |
| RF-06, RF-07 | Check-in con permisos/posición Geolocator, precisión, distancia al centro y justificación obligatoria fuera del radio. |
| RF-08, RF-09 | Checklist cumple/no cumple, observaciones y fotografías comprimidas; novedades con prioridad y foto. |
| RF-10 | Check-out guarda hora y comentario final y muestra un resumen de visita. |
| RF-11, RF-12, RF-13 | Hive conserva visitas, checklist, novedades y evidencias locales; la cola reintenta errores y sincroniza por UUID contra un servicio falso idempotente. La pantalla muestra conectividad, estado y pendientes. |
| RF-14 | Indicadores calculados para realizadas, pendientes, fuera de rango, cumplimiento y novedades abiertas. |
| RF-15 | El coordinador consulta datos de visita y checklist; el mapa de supervisión está disponible aparte. |
| RF-16 | El coordinador filtra novedades y guarda estado y comentario. |
| RF-17 | Exporta el historial como CSV compatible con Excel en el directorio temporal de la app. |
| RNF-01, RNF-02, RNF-05, RNF-06 | Almacenamiento Hive local, UUID v4 para nuevos registros, horas del dispositivo/servidor simulado, precisión GPS y compresión de fotos a máximo aproximado de 800 px/calidad 70. |
| RNF-03, RNF-04 | **Pendientes de backend**: rutas y roles demo no sustituyen autorización del servidor; las contraseñas locales de demo no equivalen a almacenamiento seguro, y no existe transporte HTTPS contra un servidor real. |
| RNF-07 | Interfaz móvil en español, estados con texto/color, controles táctiles amplios y mensajes para GPS/permisos/sincronización. |
| RNF-08 | La demo usa datos ficticios. Antes de cargar datos personales reales deben definirse minimización, retención, consentimiento y controles conforme a la Ley 1581 de 2012. |

Para una entrega operativa, sustituye `FakeRemoteDataSource` por un backend autenticado y una base de datos. El servidor debe validar identidad, rol y propiedad de cada visita, emitir la hora de recepción y aceptar eventos con UUID mediante operaciones idempotentes. La protección de rutas cliente **no sustituye** esos controles. No uses las credenciales de demostración ni los datos ficticios en producción.

En el login, usa una de estas cuentas:

| Rol | Correo | Contraseña |
|---|---|---|
| Supervisor | `supervisor@demo.com` | `123456` |
| Coordinador | `coordinador@demo.com` | `123456` |



```bash
flutter doctor --android-licenses
flutter devices
flutter run
```
