import UIKit
import Photos

class Album {

  let collection: PHAssetCollection
  var items: [Image] = []

  // MARK: - Initialization

  init(collection: PHAssetCollection) {
    self.collection = collection
  }

  func reload() {
    items = []

    let itemsFetchResult = PHAsset.fetchAssetsInAssetCollection(collection, options: Utils.fetchOptions())
    itemsFetchResult.enumerateObjectsUsingBlock { asset, _, _ in
      if let asset = asset as? PHAsset where asset.mediaType == .Image {
        self.items.append(Image(asset: asset))
      }
    }
  }
}
