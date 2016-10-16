import UIKit
import Photos

public class Video: Equatable {

  let asset: PHAsset

  var durationRequestID: Int = 0
  var duration: Double = 0

  // MARK: - Initialization

  init(asset: PHAsset) {
    self.asset = asset
  }

  func fetchDuration(_ completion: @escaping (Double) -> Void) {
    guard duration == 0
    else {
      completion(duration)
      return
    }

    if durationRequestID != 0 {
      PHImageManager.default().cancelImageRequest(PHImageRequestID(durationRequestID))
    }

    let id = PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) {
      asset, mix, _ in

      self.duration = asset?.duration.seconds ?? 0
      completion(self.duration)
    }

    durationRequestID = Int(id)
  }

  public func fetchPlayerItem(_ completion: @escaping (AVPlayerItem?) -> Void) {
    PHImageManager.default().requestPlayerItem(forVideo: asset, options: nil) {
      item, _ in

      completion(item)
    }
  }

  public func fetchAVAsset(_ completion: @escaping (AVAsset?) -> Void){
    PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) { avAsset, _, _ in
      completion(avAsset)
    }
  }

  public func fetchThumbnail(_ size: CGSize = CGSize(width: 100, height: 100), completion: @escaping (UIImage?) -> Void) {
    PHImageManager.default().requestImage(for: asset, targetSize: size,
                                                         contentMode: .aspectFill, options: nil)
    { image, _ in
      completion(image)
    }
  }
}

// MARK: - Equatable

public func ==(lhs: Video, rhs: Video) -> Bool {
  return lhs.asset == rhs.asset
}
