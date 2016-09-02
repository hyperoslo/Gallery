import UIKit
import Photos

struct Fetcher {

  // TODO: Why not use screen size?
  static func fetchImages(assets: [PHAsset], size: CGSize = CGSize(width: 720, height: 1280)) -> [UIImage] {
    let options = PHImageRequestOptions()
    options.synchronous = true

    var images = [UIImage]()
    for asset in assets {
      PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: size, contentMode: .AspectFill, options: options) { image, _ in
        if let image = image {
          images.append(image)
        }
      }
    }

    return images
  }

  static func fetchAsset(localIdentifer: String) -> PHAsset? {
    return PHAsset.fetchAssetsWithLocalIdentifiers([localIdentifer], options: nil).firstObject as? PHAsset
  }
}
