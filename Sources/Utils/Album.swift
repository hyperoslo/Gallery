import UIKit
import Photos

class Album {

  let collection: PHAssetCollection
  let itemsFetchResult: PHFetchResult
  var items: [PHAsset] = []

  // MARK: - Initialization

  init(collection: PHAssetCollection) {
    self.collection = collection
    self.itemsFetchResult = PHAsset.fetchAssetsInAssetCollection(collection, options: Utils.fetchOptions())
  }

  func reload() {
    items = []

    itemsFetchResult.enumerateObjectsUsingBlock { asset, _, _ in
      if let asset = asset as? PHAsset {
        self.items.append(asset)
      }
    }
  }
}
