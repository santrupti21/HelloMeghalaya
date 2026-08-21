# HelloMeghalaya

HelloMeghalaya is an iOS application built using UIKit and MVVM architecture.

## Project Structure

### Apps
Contains application lifecycle files.

### Home
Contains the Home screen implementation.

- View
  - ViewController
  - NavigationBarView
  - MainTabBarController

- ViewModel
  - HomeViewModel

- Models
  - HomeResponse
  - CatalogTabResponse

- TableView
  - HomeBannerTableViewCell
  - HomeSectionTableViewCell

- CollectionView
  - CatalogTabCell
  - HomeSliderCell
  - HomeContentCollectionViewCell

### Network
Contains API, image-loading and caching services.

- CatalogTabService
- HomeService
- ImageService

### Cache
Contains image caching implementation.

- ImageCache

### Assets
Contains image assets and placeholders used by the application.

- imagePlaceholder16x9
- imagePlaceholder2x3

## Architecture

The Home screen follows MVVM:

ViewController
→ HomeViewModel
→ Services
→ API

The ViewModel sends the received data back to the ViewController using a delegate.

## UI Structure

The Home screen uses:

UITableView
→ Home Banner
→ Home Sections

Each Home Section contains:

UICollectionView
→ Content Cards

The collection view cards support different layouts such as:

- 16:9 landscape
- 2:3 portrait

## Image Loading & Caching

Images are loaded asynchronously using `ImageService`.

`ImageService` uses `ImageCache` to cache downloaded images using `NSCache`.

The cache:

- Stores images using their URL as the key
- Has a maximum count limit
- Has a maximum memory cost limit
- Returns cached images before making a network request
- Can be cleared when required

Placeholder images are displayed while images are being loaded or when an image URL is unavailable.

## Git Workflow

After making changes:

```bash
git status
git add .
git commit -m "Describe your change"
git push
