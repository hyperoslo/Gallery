import UIKit
import Photos

class Video: Equatable {

  let asset: PHAsset

  init(asset: PHAsset) {
    self.asset = asset
  }
}

func ==(lhs: Video, rhs: Video) -> Bool {
  return lhs.asset == rhs.asset
}