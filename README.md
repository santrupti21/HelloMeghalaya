
HelloMeghalaya
HelloMeghalaya is an iOS application built using Swift and UIKit.

The project follows the MVVM architecture and consumes catalog APIs to display tabs, banners, content sections, categories, and paginated content.

Architecture
The application follows:

View → ViewModel → Service → API
ViewController / Custom Views
Responsible for UI and user interaction.

Displays data received from the ViewModel.

Uses delegates and closures for communication.

ViewModel
Acts as the middle layer between UI and services.

Handles API calls and prepares data for the ViewController.

Manages catalog tabs, home sections, slider data, pagination, and image loading.

Services
Responsible for network communication.

Builds API URLs and performs API requests.

Decodes JSON responses into models.

Main Features
Home Screen
Displays catalog tabs.

Loads the selected catalog.

Displays a banner/slider.

Displays multiple content sections.

Supports horizontal scrolling for content cards.

Supports different image layouts:

16:9 landscape

2:3 portrait

Catalog Tabs
Tabs are loaded from the catalog-tabs API.

When a tab is selected:

CatalogTab
    ↓
homeLink
    ↓
HomeViewModel
    ↓
HomeService
    ↓
Catalog API
Pagination
The Home screen supports pagination for catalog content.

Loads the first page when the catalog is selected.

Loads additional pages when the user scrolls near the bottom.

Maintains the current page.

Prevents duplicate API requests while loading.

Tracks whether more pages are available.

Merges newly loaded sections with existing content.

User Scrolls
     ↓
Near Bottom
     ↓
HomeViewModel
     ↓
loadNextPage()
     ↓
HomeService
     ↓
Next Page API
     ↓
Merge Content
     ↓
Update UI
Search
Implemented search functionality using:

UISearchController

UITextFieldDelegate

Combine

PassthroughSubject

Debouncing

Search flow:

User Enters Text
       ↓
UITextField
       ↓
PassthroughSubject
       ↓
Debounce
       ↓
SearchViewModel
       ↓
Search API
       ↓
Search Results
Search is restricted to a minimum number of characters before performing the search.

Movie Details
Implemented a Movie Details screen that displays detailed information for selected content.

The details screen includes:

Movie title

Description

Images/thumbnails

Genres

Content information

Video preview

Movie playback

The details screen is opened when the user selects a content item from the Home or Category screen.

Category Screen
Implemented a Category screen to display content vertically in a two-column grid.

Features:

Displays category content using UICollectionView.

Supports two-column layout.

Opens the details screen when an item is selected.

Supports navigation from Home section arrow buttons.

AVPlayer Video Playback
Implemented video playback using:

AVPlayer

AVPlayerItem

AVPlayerLayer

HLS (.m3u8)

Player controls include:

Play / Pause

15-second backward seek

15-second forward seek

Progress slider

Current time

Duration

Fullscreen

Video quality selection

Playback speed selection

HLS Video Quality Selection
Implemented dynamic HLS quality selection using AVAssetVariant.

The available variants are inspected from the HLS asset.

Supported options are displayed dynamically based on the resolutions available in the stream:

Auto

360P

480P

720P

1080P

The selected quality is applied using:

preferredMaximumResolution
Only qualities actually available in the HLS stream are displayed.

Quality Selection Flow
HLS URL
   ↓
AVURLAsset
   ↓
Load Variants
   ↓
AVAssetVariant
   ↓
Check Resolution
   ↓
Create Quality Menu
   ↓
User Selects Quality
   ↓
preferredMaximumResolution
Playback Speed
Implemented playback speed selection:

0.5x

1x

1.5x

1.75x

2x

The selected playback speed is maintained when playback is resumed.

Playback Speed Flow
User Selects Speed
       ↓
PlaybackSpeed
       ↓
Selected Rate
       ↓
AVPlayer.rate
Buffering
Implemented AVPlayer buffering monitoring using:

isPlaybackBufferEmpty

isPlaybackLikelyToKeepUp

loadedTimeRanges

timeControlStatus

A loading indicator is displayed while the player is waiting for data.

Buffering Flow
AVPlayer
   ↓
Buffer State
   ↓
Buffer Monitoring
   ↓
Buffering Indicator
   ↓
Playing / Waiting
Buffering States
isPlaybackBufferEmpty
Used to detect when the playback buffer becomes empty and the player may need more data.

isPlaybackLikelyToKeepUp
Used to determine whether the player currently has enough buffered data to continue playback.

loadedTimeRanges
Used to inspect the time ranges that have already been loaded by the player.

timeControlStatus
Used to determine the current player state:

paused
waitingToPlayAtSpecifiedRate
playing
Buffering Indicator
Added a UIActivityIndicatorView inside the video player.

The indicator:

Starts when the player is buffering.

Stops when playback starts.

Stops when playback is paused.

Stops when playback fails.

Fullscreen and Orientation
Implemented fullscreen video playback and device orientation handling.

Supports portrait and landscape orientations.

Hides the tab bar in landscape/fullscreen mode.

Shows the tab bar again in portrait mode.

Handles manual fullscreen button interaction.

Handles device orientation changes.

Orientation Flow
Portrait
   ↓
User taps Fullscreen
   ↓
Landscape
   ↓
Hide Tab Bar
   ↓
Show Landscape Player UI
When returning to portrait:

Landscape
   ↓
Exit Fullscreen
   ↓
Portrait
   ↓
Show Tab Bar
   ↓
Show Portrait UI
Landscape Player UI
Added a dedicated landscape player UI.

In landscape mode:

Displays a back button inside the player.

Displays the movie title inside the player.

Hides the portrait back button.

Hides the portrait title.

Uses the existing navigation back action.

The landscape UI is placed directly inside the playerView.

Player Settings
Added player settings inside the video player.

Settings include:

Video quality selection

Playback speed selection

Both menus are displayed directly inside the AVPlayer UI.

Player Controls
The video player contains:

┌─────────────────────────────────────┐
│  Back        Movie Title            │
│                                     │
│                                     │
│              VIDEO                  │
│                                     │
│                                     │
│ ───────────────●──────────────────  │
│ 00:15                         10:25 │
│                                     │
│  ↶15     ▶/Ⅱ     15↷    ⚙    1x    │
└─────────────────────────────────────┘
Implemented controls:

Play / Pause

Backward 15 seconds

Forward 15 seconds

Progress slider

Current playback time

Total duration

Fullscreen

Video quality

Playback speed

Buffering indicator

Networking and Data Handling
The project uses service classes for API communication.

The service layer is responsible for:

Creating API requests.

Building query parameters.

Performing network requests.

Decoding API responses.

Returning models to the ViewModel.

Image Loading and Caching
Implemented image loading through an ImageService and image caching mechanism.

The ViewModel requests images through the image service and uses cached images when available.

Navigation
Implemented navigation between:

Home
  ↓
Category
  ↓
Movie Details
  ↓
Video Player
Home content items can be selected to open the Movie Details screen.

Home section arrow buttons can open the Category screen.

UI Components
The application uses several reusable UIKit components:

UITableView

UICollectionView

Custom UITableViewCell

Custom UICollectionViewCell

Custom navigation view

UISearchController

UIStackView

UIButton

UILabel

UIImageView

UIActivityIndicatorView

UISlider

Technologies Used
Swift

UIKit

MVVM

Combine

AVFoundation

AVPlayer

HLS

Auto Layout

UICollectionView

UITableView

UISearchController

KVO

Async/Await

REST APIs

JSON

SPM

CocoaPods

Project Structure
HelloMeghalaya
│
├── ViewControllers
│   ├── ViewController
│   ├── CategoryViewController
│   ├── MovieDetailsViewController
│   ├── MoreViewController
│   └── LoginViewController
│
├── ViewModels
│   ├── HomeViewModel
│   └── SearchViewModel
│
├── Views
│   ├── NavigationBarView
│   ├── HomeBannerTableViewCell
│   ├── HomeSectionTableViewCell
│   ├── HomeSliderCell
│   └── HomeContentCollectionViewCell
│
├── Services
│   ├── HomeService
│   ├── CatalogTabsService
│   └── ImageService
│
└── Models
    ├── HomeResponse
    ├── HomeData
    ├── HomeSection
    └── HomeItem
Key Learning Areas
During the implementation, the project covered practical learning of:

MVVM architecture

UIKit programmatic UI

Auto Layout

Delegates

Closures

Combine

Pagination

API integration

JSON decoding

Image caching

UICollectionView

UITableView

UISearchController

AVPlayer

AVPlayerItem

AVPlayerLayer

HLS streaming

HLS variants

Video quality selection

Playback speed

Buffering

KVO

loadedTimeRanges

Device orientation

Fullscreen video playback

Player UI controls

Async/Await

Project Status
The HelloMeghalaya iOS application currently includes:

Home screen

Catalog tabs

Banner/slider

Content sections

Pagination

Search

Category screen

Movie Details screen

AVPlayer video playback

HLS quality selection

Playback speed selection

Buffering detection

Buffering indicator

Fullscreen support

Portrait and landscape UI

Player settings

Player controls

Image loading and caching

Project
HelloMeghalaya iOS Application

Built with Swift + UIKit + MVVM.


readme file u give

Yes — you mean the actual README.md file I created earlier, not just the text.

Here it is:

Download README.md


README.md
Document


full from first till now file

Yes. I created the full README.md from the beginning through all the work we've covered so far.

Download the complete README.md 


README.md
Document


README.md


HelloMeghalaya
HelloMeghalaya is an iOS application built using Swift and UIKit.

The project follows the MVVM architecture and consumes catalog APIs to display tabs, banners, content sections, categories, and paginated content.

Architecture
The application follows:

View → ViewModel → Service → API
ViewController / Custom Views
Responsible for UI and user interaction.

Displays data received from the ViewModel.

Uses delegates and closures for communication.

ViewModel
Acts as the middle layer between UI and services.

Handles API calls and prepares data for the ViewController.

Manages catalog tabs, home sections, slider data, pagination, and image loading.

Services
Responsible for network communication.

Builds API URLs and performs API requests.

Decodes JSON responses into models.

Main Features
Home Screen
Displays catalog tabs.

Loads the selected catalog.

Displays a banner/slider.

Displays multiple content sections.

Supports horizontal scrolling for content cards.

Supports different image layouts:

16:9 landscape

2:3 portrait

Catalog Tabs
Tabs are loaded from the catalog-tabs API.

When a tab is selected:

CatalogTab
    ↓
homeLink
    ↓
HomeViewModel
    ↓
HomeService
    ↓
Catalog API
Pagination
The Home screen supports pagination for catalog content.

Loads the first page when the catalog is selected.

Loads additional pages when the user scrolls near the bottom.

Maintains the current page.

Prevents duplicate API requests while loading.

Tracks whether more pages are available.

Merges newly loaded sections with existing content.

User Scrolls
     ↓
Near Bottom
     ↓
HomeViewModel
     ↓
loadNextPage()
     ↓
HomeService
     ↓
Next Page API
     ↓
Merge Content
     ↓
Update UI
Search
Implemented search functionality using:

UISearchController

UITextFieldDelegate

Combine

PassthroughSubject

Debouncing

Search flow:

User Enters Text
       ↓
UITextField
       ↓
PassthroughSubject
       ↓
Debounce
       ↓
SearchViewModel
       ↓
Search API
       ↓
Search Results
Search is restricted to a minimum number of characters before performing the search.

Movie Details
Implemented a Movie Details screen that displays detailed information for selected content.

The details screen includes:

Movie title

Description

Images/thumbnails

Genres

Content information

Video preview

Movie playback

The details screen is opened when the user selects a content item from the Home or Category screen.

Category Screen
Implemented a Category screen to display content vertically in a two-column grid.

Features:

Displays category content using UICollectionView.

Supports two-column layout.

Opens the details screen when an item is selected.

Supports navigation from Home section arrow buttons.

AVPlayer Video Playback
Implemented video playback using:

AVPlayer

AVPlayerItem

AVPlayerLayer

HLS (.m3u8)

Player controls include:

Play / Pause

15-second backward seek

15-second forward seek

Progress slider

Current time

Duration

Fullscreen

Video quality selection

Playback speed selection

HLS Video Quality Selection
Implemented dynamic HLS quality selection using AVAssetVariant.

The available variants are inspected from the HLS asset.

Supported options are displayed dynamically based on the resolutions available in the stream:

Auto

360P

480P

720P

1080P

The selected quality is applied using:

preferredMaximumResolution
Only qualities actually available in the HLS stream are displayed.

Quality Selection Flow
HLS URL
   ↓
AVURLAsset
   ↓
Load Variants
   ↓
AVAssetVariant
   ↓
Check Resolution
   ↓
Create Quality Menu
   ↓
User Selects Quality
   ↓
preferredMaximumResolution
Playback Speed
Implemented playback speed selection:

0.5x

1x

1.5x

1.75x

2x

The selected playback speed is maintained when playback is resumed.

Playback Speed Flow
User Selects Speed
       ↓
PlaybackSpeed
       ↓
Selected Rate
       ↓
AVPlayer.rate
Buffering
Implemented AVPlayer buffering monitoring using:

isPlaybackBufferEmpty

isPlaybackLikelyToKeepUp

loadedTimeRanges

timeControlStatus

A loading indicator is displayed while the player is waiting for data.

Buffering Flow
AVPlayer
   ↓
Buffer State
   ↓
Buffer Monitoring
   ↓
Buffering Indicator
   ↓
Playing / Waiting
Buffering States
isPlaybackBufferEmpty
Used to detect when the playback buffer becomes empty and the player may need more data.

isPlaybackLikelyToKeepUp
Used to determine whether the player currently has enough buffered data to continue playback.

loadedTimeRanges
Used to inspect the time ranges that have already been loaded by the player.

timeControlStatus
Used to determine the current player state:

paused
waitingToPlayAtSpecifiedRate
playing
Buffering Indicator
Added a UIActivityIndicatorView inside the video player.

The indicator:

Starts when the player is buffering.

Stops when playback starts.

Stops when playback is paused.

Stops when playback fails.

Fullscreen and Orientation
Implemented fullscreen video playback and device orientation handling.

Supports portrait and landscape orientations.

Hides the tab bar in landscape/fullscreen mode.

Shows the tab bar again in portrait mode.

Handles manual fullscreen button interaction.

Handles device orientation changes.

Orientation Flow
Portrait
   ↓
User taps Fullscreen
   ↓
Landscape
   ↓
Hide Tab Bar
   ↓
Show Landscape Player UI
When returning to portrait:

Landscape
   ↓
Exit Fullscreen
   ↓
Portrait
   ↓
Show Tab Bar
   ↓
Show Portrait UI
Landscape Player UI
Added a dedicated landscape player UI.

In landscape mode:

Displays a back button inside the player.

Displays the movie title inside the player.

Hides the portrait back button.

Hides the portrait title.

Uses the existing navigation back action.

The landscape UI is placed directly inside the playerView.

Player Settings
Added player settings inside the video player.

Settings include:

Video quality selection

Playback speed selection

Both menus are displayed directly inside the AVPlayer UI.

Player Controls
The video player contains:

┌─────────────────────────────────────┐
│  Back        Movie Title            │
│                                     │
│                                     │
│              VIDEO                  │
│                                     │
│                                     │
│ ───────────────●──────────────────  │
│ 00:15                         10:25 │
│                                     │
│  ↶15     ▶/Ⅱ     15↷    ⚙    1x    │
└─────────────────────────────────────┘
Implemented controls:

Play / Pause

Backward 15 seconds

Forward 15 seconds

Progress slider

Current playback time

Total duration

Fullscreen

Video quality

Playback speed

Buffering indicator

Networking and Data Handling
The project uses service classes for API communication.

The service layer is responsible for:

Creating API requests.

Building query parameters.

Performing network requests.

Decoding API responses.

Returning models to the ViewModel.

Image Loading and Caching
Implemented image loading through an ImageService and image caching mechanism.

The ViewModel requests images through the image service and uses cached images when available.

Navigation
Implemented navigation between:

Home
  ↓
Category
  ↓
Movie Details
  ↓
Video Player
Home content items can be selected to open the Movie Details screen.

Home section arrow buttons can open the Category screen.

UI Components
The application uses several reusable UIKit components:

UITableView

UICollectionView

Custom UITableViewCell

Custom UICollectionViewCell

Custom navigation view

UISearchController

UIStackView

UIButton

UILabel

UIImageView

UIActivityIndicatorView

UISlider

Technologies Used
Swift

UIKit

MVVM

Combine

AVFoundation

AVPlayer

HLS

Auto Layout

UICollectionView

UITableView

UISearchController

KVO

Async/Await

REST APIs

JSON

SPM

CocoaPods

Project Structure
HelloMeghalaya
│
├── ViewControllers
│   ├── ViewController
│   ├── CategoryViewController
│   ├── MovieDetailsViewController
│   ├── MoreViewController
│   └── LoginViewController
│
├── ViewModels
│   ├── HomeViewModel
│   └── SearchViewModel
│
├── Views
│   ├── NavigationBarView
│   ├── HomeBannerTableViewCell
│   ├── HomeSectionTableViewCell
│   ├── HomeSliderCell
│   └── HomeContentCollectionViewCell
│
├── Services
│   ├── HomeService
│   ├── CatalogTabsService
│   └── ImageService
│
└── Models
    ├── HomeResponse
    ├── HomeData
    ├── HomeSection
    └── HomeItem
Key Learning Areas
During the implementation, the project covered practical learning of:

MVVM architecture

UIKit programmatic UI

Auto Layout

Delegates

Closures

Combine

Pagination

API integration

JSON decoding

Image caching

UICollectionView

UITableView

UISearchController

AVPlayer

AVPlayerItem

AVPlayerLayer

HLS streaming

HLS variants

Video quality selection

Playback speed

Buffering

KVO

loadedTimeRanges

Device orientation

Fullscreen video playback

Player UI controls

Async/Await

Project Status
The HelloMeghalaya iOS application currently includes:

Home screen

Catalog tabs

Banner/slider

Content sections

Pagination

Search

Category screen

Movie Details screen

AVPlayer video playback

HLS quality selection

Playback speed selection

Buffering detection

Buffering indicator

Fullscreen support

Portrait and landscape UI

Player settings

Player controls

Image loading and caching

Project
HelloMeghalaya iOS Application

Built with Swift + UIKit + MVVM.


