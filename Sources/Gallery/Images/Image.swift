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

// MARK: - UIImage with metadata typealias
public typealias UIImageData = (image: UIImage, metadata: CGImageMetadata)

// MARK: - UIImage

extension Image {

  /// Resolve UIImage and it's metadata asynchronously
  /// - Parameters:
  ///   -  completion: A block to be called when the process is complete. The block takes the resolved UIImage and its CGImageMetadata
  ///    as parameters.
  public func resolveImageData(completion: @escaping (UIImageData) -> Void) {
    let options = PHImageRequestOptions()
    options.isNetworkAccessAllowed = true
    options.deliveryMode = .highQualityFormat
    PHImageManager.default().requestImageData(for: asset, options: options) { imageData, dataUTI, _, _ in
      let destData = NSMutableData() as CFMutableData
      guard let imageData = imageData,
            let dataUTI = dataUTI,
            let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil),
            let imageDestination = CGImageDestinationCreateWithData(destData, dataUTI as CFString, 1, nil),
            let imageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, nil) else {
        return
      }
      CGImageDestinationAddImage(imageDestination, imageRef, nil)
      CGImageDestinationFinalize(imageDestination)
      guard let imageMetadata = CGImageSourceCopyMetadataAtIndex(imageSource, 0, nil),
            let image = UIImage(data: destData as Data) else {
        return
      }
      completion(UIImageData(image, imageMetadata))
    }
  }

  /// Resolve UIImage asynchronously
  /// - Parameters:
  ///   - completion: A block to be called when image resolving is complete. The block takes the resolved UIImage as a parameter.
  public func resolve(completion: @escaping (UIImage?) -> Void) {
    let options = PHImageRequestOptions()
    options.isNetworkAccessAllowed = true
    options.deliveryMode = .highQualityFormat

    PHImageManager.default().requestImage(
      for: asset,
      targetSize: PHImageManagerMaximumSize,
      contentMode: .default,
      options: options) { (image, _) in
      completion(image)
    }
  }

  /// Resolve an array of Images and their metadata
  /// - Parameters:
  ///   - images: The array of Images
  ///   -  completion: A block to be called when the process is complete. The block takes the array of resolved UIImages and their
  ///    CGImageMetadata as parameters.
  public static func resolveImageData(images: [Image], completion: @escaping ([UIImageData]) -> Void) {
    let dispatchGroup = DispatchGroup()
    var convertedImages = [Int: UIImageData]()

    for (index, image) in images.enumerated() {
      dispatchGroup.enter()

      image.resolveImageData(completion: { resolvedImage, metadata in
        convertedImages[index] = (resolvedImage, metadata)
        dispatchGroup.leave()
      })
    }

    dispatchGroup.notify(queue: .main, execute: {
      let sortedImages = convertedImages
        .sorted(by: { $0.key < $1.key })
        .map({ $0.value })
      completion(sortedImages)
    })
  }

  /// Resolve an array of Images
  /// - Parameters:
  ///   - images: The array of Images
  ///   - completion: A block to be called when the process is complete. The block takes the array of resolved UIImages as a parameter.
  public static func resolve(images: [Image], completion: @escaping ([UIImage?]) -> Void) {
    let dispatchGroup = DispatchGroup()
    var convertedImages = [Int: UIImage]()

    for (index, image) in images.enumerated() {
      dispatchGroup.enter()

      image.resolve(completion: { resolvedImage in
        if let resolvedImage = resolvedImage {
          convertedImages[index] = resolvedImage
        }

        dispatchGroup.leave()
      })
    }

    dispatchGroup.notify(queue: .main, execute: {
      let sortedImages = convertedImages
        .sorted(by: { $0.key < $1.key })
        .map({ $0.value })
      completion(sortedImages)
    })
  }
}

// MARK: - Equatable

public func == (lhs: Image, rhs: Image) -> Bool {
  return lhs.asset == rhs.asset
}
