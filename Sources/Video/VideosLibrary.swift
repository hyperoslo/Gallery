import UIKit
import Photos

class VideosLibrary {

  var items: [PHAsset] = []
  var fetchResults: PHFetchResult?

  // MARK: - Initialization

  init() {

  }

  // MARK: - Logic

  func reload() {
    fetchResults = PHAsset.fetchAssetsWithMediaType(.Video, options: Utils.fetchOptions())

    items = []
    fetchResults?.enumerateObjectsUsingBlock { asset, _, _ in
      if let asset = asset as? PHAsset {
        self.items.append(asset)
      }
    }
  }
}

