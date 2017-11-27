import UIKit
import Photos

/// Wrap a PHAsset
public class Image: Equatable {

  public let asset: PHAsset

  // MARK: - Initialization
  
  init(asset: PHAsset) {
    self.asset = asset
  }
}

// MARK: - UIImage

extension Image {

  /// Resolve UIImage synchronously
  ///
  /// - Parameter size: The target size
  /// - Returns: The resolved UIImage, otherwise nil
  public func resolve(size: CGSize) -> UIImage? {
    let options = PHImageRequestOptions()
    options.isSynchronous = true
    options.isNetworkAccessAllowed = true

    var result: UIImage? = nil

    PHImageManager.default().requestImage(
      for: asset,
      targetSize: size,
      contentMode: .aspectFit,
      options: options) { (image, _) in
        result = image
    }

    return result
  }

  /// Resolve an array of Image
  ///
  /// - Parameters:
  ///   - images: The array of Image
  ///   - size: The target size for all images
  ///   - completion: Called when operations completion
  public static func resolve(images: [Image], size: CGSize, completion: @escaping ([UIImage?]) -> Void) {
    DispatchQueue.global().async {
      let uiImages = images.map({ $0.resolve(size: size) })
      DispatchQueue.main.async {
        completion(uiImages)
      }
    }
  }
}

// MARK: - Equatable

public func == (lhs: Image, rhs: Image) -> Bool {
  return lhs.asset == rhs.asset
}
