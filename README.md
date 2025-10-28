# Space Flight News Challenge

Aplicación iOS que consume la API pública de [Space Flight News](https://www.spaceflightnewsapi.net/) para listar los artículos más recientes y permitir búsquedas.

## Configuración y Ejecución

1. Clonar el repositorio
2. Abrir en excode SpaceFlightNewsChallenge.xcodeproj
3. Iniciar compilacion presionando (`⌘ + R`) con un destino de ejecucion seleccionado (fisico o emulador).

### Datos de hardware y software de desarrollo

- Mac M3 2023 con macOS 26
- Xcode 26 con swift 6
- Dispositivo fisico de ejecucion: 13 Pro, iOS 26

### Requisitos

- Minimum deployment version: iOS 26
- Xcode 26

## Funcionalidades

- Listado de artículos recientes con paginación automática al llegar al final de la lista.
- Estado visual consistente: placeholders con shimmer durante carga, mensajes de error recuperables, vacío amigable.
- Búsqueda con historial persistido usando `SwiftData`; se puede reutilizar cada término o eliminar entradas.
- Detalle de cada artículo con imagen, resumen, autor, fecha formateada y acceso directo al artículo original.

## Capturas de pantalla

[app-images-example.png](app-images-example.png)

## Frameworks, Arquitectura y Patrones de diseño

- `SwiftUI` + `MVVM` para separar la lógica de presentación de las vistas declarativas.
- Patrón `Repository` que encapsula el acceso a la API y la paginación, desacoplando la capa de datos del view model.
- Patrón `Coordinator` para manejar navegación sin que las vistas conozcan rutas concretas.
- `AppDependencies` actúa como contenedor centralizado para las dependencias principales.
- `Delegate` para delegar en la vista padre la función de busqueda.

## Pruebas

- Tests unitarios que cubren:
  - `HomeViewModel`: carga inicial, paginación, búsqueda, limpieza de búsqueda.
  - `HomeView`: helpers para texto de búsqueda trimmeado y retención del view model inyectado.
  - `SearchViewModel`: delegates, trims y acciones de cancelación/clear.
  - `SearchView`: helpers de input vacío/trimmed.
  - `ArticleDetailView`: formateo de fechas y fallbacks de autores/enlaces.

## Manejo de Errores

- La vista principal muestra placeholders de carga, mensajes informativos y botón de reintento en caso de perder conexion de internet.
- `APIClient` centraliza el logging de requests/responses y mapea status HTTP / errores de parseo a `APIError`.

## Notas Finales

- `SwiftData` mantiene el historial de búsqueda y elimina automáticamente los términos más antiguos para conservar solo los últimos 10.
- El coordinator maneja la navegacion hacia el buscador con animaciones suaves y a la vista de detalle del articulo, aislando la navegación del resto de la app.
- Los recursos (colores, assets) siguen las guías de diseño de iOS, con soporte para modo claro.
