# HelloMeghalaya

HelloMeghalaya is an iOS application built using Swift and UIKit for exploring movies, shows, episodes, music, and other content from Meghalaya.

## Features

- Home screen with dynamic content
- Categories and content sections
- Search functionality
- Movie details
- TV show details
- Episode listing
- Language-based episode selection
- Episode details
- Add to list
- Like functionality
- Share content
- Recommended content
- Image caching
- Pagination
- Video playback using AVPlayer
- Responsive UIKit-based UI

## Tech Stack

- Swift
- UIKit
- MVVM Architecture
- Combine
- URLSession
- AVPlayer
- Auto Layout
- UICollectionView
- UITableView
- Swift Concurrency (`async/await`)
- Swift Package Manager

## Architecture

The application follows the **MVVM (Model-View-ViewModel)** architecture.

```text
View
  ↓
ViewModel
  ↓
Service / Network Layer
  ↓
API
