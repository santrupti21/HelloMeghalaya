# HelloMeghalaya

HelloMeghalaya is an iOS application built using **Swift and UIKit**.  
The project follows the **MVVM architecture** and consumes catalog APIs to display tabs, banners, content sections, categories, and paginated content.

## Architecture

The application follows:

**View → ViewModel → Service → API**

- **ViewController / Custom Views**
  - Responsible for UI and user interaction.
  - Displays data received from the ViewModel.
  - Uses delegates and closures for communication.

- **ViewModel**
  - Acts as the middle layer between UI and services.
  - Handles API calls and prepares data for the ViewController.
  - Manages catalog tabs, home sections, slider data, pagination, and image loading.

- **Services**
  - Responsible for network communication.
  - Builds API URLs and performs API requests.
  - Decodes JSON responses into models.

## Main Features

### Home Screen

- Displays catalog tabs.
- Loads the selected catalog.
- Displays a banner/slider.
- Displays multiple content sections.
- Supports horizontal scrolling for content cards.
- Supports different image layouts:
  - 16:9 landscape
  - 2:3 portrait

### Catalog Tabs

Tabs are loaded from the catalog-tabs API.

When a tab is selected:

```text
CatalogTab
    ↓
homeLink
    ↓
HomeViewModel
    ↓
HomeService
    ↓
Catalog API
