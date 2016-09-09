import UIKit
import Photos

class VideosLibrary {

  var items: [Video] = []
  var fetchResults: PHFetchResult?

  // MARK: - Initialization

  init() {

  }

  // MARK: - Logic

  func reload(completion: () -> Void) {
    Dispatch.background {
      self.reloadSync()
      Dispatch.main {
        completion()
      }
    }
  }

  private func reloadSync() {
    fetchResults = PHAsset.fetchAssetsWithMediaType(.Video, options: Utils.fetchOptions())

    items = []
    fetchResults?.enumerateObjectsUsingBlock { asset, _, _ in
      if let asset = asset as? PHAsset {
        self.items.append(Video(asset: asset))
      }
    }
  }
}

