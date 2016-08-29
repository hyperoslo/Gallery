import UIKit
import Photos

class Album {

  let collection: PHAssetCollection
  let itemsFetchResult: PHFetchResult
  var items: [PHAsset] = []

  // MARK: - Initialization

  init(collection: PHAssetCollection) {
    self.collection = collection
    self.itemsFetchResult = PHAsset.fetchAssetsInAssetCollection(collection, options: nil)
  }

  func reload() {
    items = []

    itemsFetchResult.enumerateObjectsUsingBlock { asset, _, _ in
      if let asset = asset as? PHAsset {
        self.items.append(asset)
      }
    }
  }

  func fetchThumbnail(completion: (UIImage? -> Void)) {
    guard let item = items.first
    else {
      completion(nil)
      return
    }

    Fetcher.resolveAsset(item, size: CGSize(width: 60, height: 60), completion: completion)
  }
}
