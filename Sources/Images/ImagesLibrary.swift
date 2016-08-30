import UIKit
import Photos

class ImagesLibrary {

  var albums: [Album] = []
  var albumsFetchResults: [PHFetchResult] = []

  // MARK: - Initialization

  init() {

  }

  // MARK: - Logic

  func reload() {
    let types: [PHAssetCollectionType] = [.SmartAlbum, .Album]

    albumsFetchResults = types.map {
      return PHAssetCollection.fetchAssetCollectionsWithType($0, subtype: .Any, options: nil)
    }

    albums = []

    for result in albumsFetchResults {
      result.enumerateObjectsUsingBlock { collection, _, _ in
        if let collection = collection as? PHAssetCollection {
          let album = Album(collection: collection)
          album.reload()

          if !album.items.isEmpty {
            self.albums.append(album)
          }
        }
      }
    }
  }
}
