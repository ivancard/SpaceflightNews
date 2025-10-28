# Space Flight News Challenge

Aplicación iOS que consume la API pública de [Space Flight News](https://www.spaceflightnewsapi.net/) para listar los artículos más recientes, permitir búsquedas y ofrecer detalles enriquecidos.

## Requisitos

- Xcode 16 (toolchain Swift 6, probado con Xcode 16.0).
- iOS 17+ (probado en simulador iPhone 13 Pro con iOS 17 / 18 y en dispositivo físico con iOS 17).
- La app usa `SwiftData`, disponible desde iOS 17.

## Configuración y Ejecución

1. Clonar el repositorio y abrir `SpaceFlightNewsChallenge.xcodeproj` en Xcode 16.
2. Seleccionar el esquema `SpaceFlightNewsChallenge`.
3. Elegir un destino iOS 17+ (por ejemplo, iPhone 13 Pro) y ejecutar (`⌘ + R`).

## Arquitectura y Patrones

- `SwiftUI` + `MVVM` para separar la lógica de presentación (`HomeViewModel`, `SearchViewModel`) de las vistas declarativas (`HomeView`, `SearchView`, `ArticleDetailView`).
- Patrón `Repository` (`ArticlesRepository`) que encapsula el acceso a la API y la paginación, desacoplando la capa de datos del view model.
- Patrón `Coordinator` (`AppCoordinator`, `Router`) para manejar navegación (stack + overlays) sin que las vistas conozcan rutas concretas.
- `AppDependencies` actúa como contenedor centralizado para las dependencias principales (API client, repository).
- `OSLog` via `AppLogger` centraliza los logs de red y de view models, cumpliendo con los requerimientos de trazabilidad para developers.

## Funcionalidades

- Listado de artículos recientes con paginación automática al llegar al final de la lista.
- Estado visual consistente: placeholders con shimmer durante carga, mensajes de error recuperables, vacío amigable.
- Búsqueda con historial persistido usando `SwiftData`; se puede reutilizar cada término o eliminar entradas.
- Detalle de cada artículo con imagen, resumen, autor, fecha formateada y acceso directo al artículo original.
- Manejo de errores orientado al usuario (copys localizados) y al desarrollador (logs detallados).

## Pruebas

- Tests unitarios y de vista (`SpaceFlightNewsChallengeTests`) cubren:
  - `HomeViewModel`: carga inicial, paginación, búsqueda, limpieza de búsqueda.
  - `HomeView`: helpers para texto de búsqueda trimmeado y retención del view model inyectado.
  - `SearchViewModel`: delegates, trims y acciones de cancelación/clear.
  - `SearchView`: helpers de input vacío/trimmed.
  - `ArticleDetailView`: formateo de fechas y fallbacks de autores/enlaces.
- Para ejecutar: `xcodebuild test -scheme SpaceFlightNewsChallenge -destination 'platform=iOS Simulator,name=iPhone 16,OS=26.0' -skip-testing:SpaceFlightNewsChallengeUITests`

## Manejo de Errores

- Vista principal muestra placeholders de carga, mensajes amigables y botón de reintento.
- `HomeViewModel` traduce errores de red a mensajes localizados (`HomeViewError`) y registra detalles con `AppLogger`.
- `APIClient` centraliza el logging de requests/responses y mapea status HTTP / errores de parseo a `APIError`.

## Notas Finales

- `SwiftData` mantiene el historial de búsqueda y soporta pruning automático para limitar la lista a los últimos 10 términos.
- El coordinator maneja overlays (buscador) con animaciones suaves, aislando la navegación del resto de la app.
- Los recursos (colores, assets) siguen las guías de diseño de iOS, con soporte para modo claro.
