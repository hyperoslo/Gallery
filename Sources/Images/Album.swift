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

    let itemsFetchResult = PHAsset.fetchAssets(in: collection, options: Utils.fetchOptions())
    itemsFetchResult.enumerateObjects({ (asset, count, stop) in
      if asset.mediaType == .image {
        self.items.append(Image(asset: asset))
      }
    })
  }
}

class VideoAlbum: MediaAlbum {
    
    var videos: [Video] = []
    
    var title: String? {
        return "All Videos"
    }
    
    var count: String? {
        return "\(videos.count)"
    }
    
    var mode: MediaMode {
        return .video(videos: videos)
    }
    
    // todo:- update reload for videos
    func reload() {
    
    }
    
    convenience init (videos: [Video]) {
        self.init()
        self.videos = videos
    }
}

extension Album: MediaAlbum {
    
    var title: String? {
        return collection.localizedTitle
    }
    
    var count: String? {
        return "\(items.count)"
    }
    
    var mode: MediaMode {
        return .image(images: items)
    }
}
