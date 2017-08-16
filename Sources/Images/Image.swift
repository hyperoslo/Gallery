import UIKit
import Photos

public class Image: Equatable {

  public let asset: PHAsset

  // MARK: - Initialization
  
  init(asset: PHAsset) {
    self.asset = asset
  }
}

// MARK: - UIImage

extension Image {
  public func uiImage(ofSize size: CGSize) -> UIImage? {
    let options = PHImageRequestOptions()
    options.isSynchronous = true

    var result: UIImage? = nil

    PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options) { (image, _) in
      result = image
    }

    return result
  }
}

// MARK: - Equatable

public func ==(lhs: Image, rhs: Image) -> Bool {
  return lhs.asset == rhs.asset
}
