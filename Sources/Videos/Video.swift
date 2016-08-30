import UIKit
import Photos

class Video: Equatable {

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

      print(asset)
    }

    durationRequestID = Int(id)
  }
}

// MARK: - Equatable

func ==(lhs: Video, rhs: Video) -> Bool {
  return lhs.asset == rhs.asset
}