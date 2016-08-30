import UIKit
import Photos

class Image: Equatable {

  let asset: PHAsset

  // MARK: - Initialization
  
  init(asset: PHAsset) {
    self.asset = asset
  }
}

// MARK: - Equatable

func ==(lhs: Image, rhs: Image) -> Bool {
  return lhs.asset == rhs.asset
}

