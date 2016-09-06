import UIKit
import Photos

extension UIImageView {

  func g_loadImage(asset: PHAsset) {
    guard frame.size != CGSize.zero
      else {
        image = Bundle.image("gallery_placeholder")
        return
    }

    if tag == 0 {
      image = Bundle.image("gallery_placeholder")
    } else {
      PHImageManager.defaultManager().cancelImageRequest(PHImageRequestID(tag))
    }

    let options = PHImageRequestOptions()

    let id = PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: frame.size,
                                                                  contentMode: .AspectFill, options: options)
    { [weak self] image, _ in

      self?.image = image
    }
    
    tag = Int(id)
  }
}
