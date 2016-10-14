import UIKit
import Photos

open class Image: Equatable {

  let asset: PHAsset

  // MARK: - Initialization
  
  init(asset: PHAsset) {
    self.asset = asset
  }
}

// MARK: - Equatable

public func ==(lhs: Image, rhs: Image) -> Bool {
  return lhs.asset == rhs.asset
}

