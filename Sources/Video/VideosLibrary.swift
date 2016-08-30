import UIKit
import Photos

class VideosLibrary {

  let title = "ALL VIDEOS"
  var items: [PHAsset] = []
  var fetchResults: PHFetchResult?

  // MARK: - Initialization

  init() {

  }

  // MARK: - Logic

  func reload() {
    fetchResults = PHAsset.fetchAssetsWithMediaType(.Video, options: nil)

    items = []
    fetchResults?.enumerateObjectsUsingBlock { asset, _, _ in
      if let asset = asset as? PHAsset {
        self.items.append(asset)
      }
    }
  }
}

