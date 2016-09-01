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

  func fetchDuration(completion: Double -> Void) {
    guard duration == 0
    else {
      completion(duration)
      return
    }

    if durationRequestID != 0 {
      PHImageManager.defaultManager().cancelImageRequest(PHImageRequestID(durationRequestID))
    }

    let id = PHImageManager.defaultManager().requestAVAssetForVideo(asset, options: nil) {
      asset, mix, _ in

      self.duration = asset?.duration.seconds ?? 0
      completion(self.duration)
    }

    durationRequestID = Int(id)
  }

  func fetchPlayerItem(completion: AVPlayerItem? -> Void) {
    PHImageManager.defaultManager().requestPlayerItemForVideo(asset, options: nil) {
      item, _ in

      completion(item)
    }
  }
}

// MARK: - Equatable

public func ==(lhs: Video, rhs: Video) -> Bool {
  return lhs.asset == rhs.asset
}