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
Contains API and image-loading services.

- CatalogTabService
- HomeService
- ImageService

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

## Git Workflow

After making changes:

```bash
git status
git add .
git commit -m "Describe your change"
git push