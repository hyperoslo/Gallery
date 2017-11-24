import UIKit
import Photos

/// Wrap a PHAsset for video
public class Video: Equatable {

  public let asset: PHAsset

  var durationRequestID: Int = 0
  var duration: Double = 0

  // MARK: - Initialization

  init(asset: PHAsset) {
    self.asset = asset
  }

  /// Fetch video duration asynchronously
  ///
  /// - Parameter completion: Called when finish
  func fetchDuration(_ completion: @escaping (Double) -> Void) {
    guard duration == 0
    else {
      DispatchQueue.main.async {
        completion(self.duration)
      }
      return
    }

    if durationRequestID != 0 {
      PHImageManager.default().cancelImageRequest(PHImageRequestID(durationRequestID))
    }

    let id = PHImageManager.default().requestAVAsset(forVideo: asset, options: videoOptions) {
      asset, mix, _ in

      self.duration = asset?.duration.seconds ?? 0
      DispatchQueue.main.async {
        completion(self.duration)
      }
    }

    durationRequestID = Int(id)
  }

  /// Fetch AVPlayerItem asynchronoulys
  ///
  /// - Parameter completion: Called when finish
  public func fetchPlayerItem(_ completion: @escaping (AVPlayerItem?) -> Void) {
    PHImageManager.default().requestPlayerItem(forVideo: asset, options: videoOptions) {
      item, _ in

      DispatchQueue.main.async {
        completion(item)
      }
    }
  }

  /// Fetch AVAsset asynchronoulys
  ///
  /// - Parameter completion: Called when finish
  public func fetchAVAsset(_ completion: @escaping (AVAsset?) -> Void) {
    PHImageManager.default().requestAVAsset(forVideo: asset, options: videoOptions) { avAsset, _, _ in
      DispatchQueue.main.async {
        completion(avAsset)
      }
    }
  }

  /// Fetch thumbnail image for this video asynchronoulys
  ///
  /// - Parameter size: The preferred size
  /// - Parameter completion: Called when finish
  public func fetchThumbnail(size: CGSize = CGSize(width: 100, height: 100), completion: @escaping (UIImage?) -> Void) {
    let options = PHImageRequestOptions()
    options.isNetworkAccessAllowed = true

    PHImageManager.default().requestImage(
      for: asset,
      targetSize: size,
      contentMode: .aspectFill,
      options: options) { image, _ in
        DispatchQueue.main.async {
          completion(image)
        }
    }
  }

  // MARK: - Helper

  private var videoOptions: PHVideoRequestOptions {
    let options = PHVideoRequestOptions()
    options.isNetworkAccessAllowed = true

    return options
  }
}

// MARK: - Equatable

public func ==(lhs: Video, rhs: Video) -> Bool {
  return lhs.asset == rhs.asset
}
