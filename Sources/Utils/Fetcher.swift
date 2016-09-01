import UIKit
import Photos

struct Fetcher {

  public static func fetch(completion: (assets: [PHAsset]) -> Void) {
    let fetchOptions = PHFetchOptions()
    let authorizationStatus = PHPhotoLibrary.authorizationStatus()
    var fetchResult: PHFetchResult?

    guard authorizationStatus == .Authorized else { return }

    if fetchResult == nil {
      fetchResult = PHAsset.fetchAssetsWithMediaType(.Image, options: fetchOptions)
    }

    if fetchResult?.count > 0 {
      var assets = [PHAsset]()
      fetchResult?.enumerateObjectsUsingBlock { object, index, stop in
        if let asset = object as? PHAsset {
          assets.insert(asset, atIndex: 0)
        }
      }

      Dispatch.main {
        completion(assets: assets)
      }
    }
  }

  static func fetchImages(assets: [PHAsset], size: CGSize = UIScreen.mainScreen().bounds.size) -> [UIImage] {
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
