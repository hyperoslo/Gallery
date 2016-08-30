import UIKit
import Photos

class Image: Equatable {

  let asset: PHAsset

  init(asset: PHAsset) {
    self.asset = asset
  }
}

func ==(lhs: Image, rhs: Image) -> Bool {
  return lhs.asset == rhs.asset
}

