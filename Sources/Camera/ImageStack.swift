import Photos

class ImageStack {

  struct Notifications {
    static let imageDidPush = "imageDidPush"
    static let imageDidDrop = "imageDidDrop"
    static let stackDidReload = "stackDidReload"
  }

  var assets = [PHAsset]()
  let imageKey = "image"

  func pushAsset(asset: PHAsset) {
    assets.append(asset)
    NSNotificationCenter.defaultCenter().postNotificationName(Notifications.imageDidPush, object: self, userInfo: [imageKey: asset])
  }

  func dropAsset(asset: PHAsset) {
    assets = assets.filter() {$0 != asset}
    NSNotificationCenter.defaultCenter().postNotificationName(Notifications.imageDidDrop, object: self, userInfo: [imageKey: asset])
  }

  func resetAssets(assets: [PHAsset]) {
    self.assets = assets
    NSNotificationCenter.defaultCenter().postNotificationName(Notifications.stackDidReload, object: self, userInfo: nil)
  }

  func containsAsset(asset: PHAsset) -> Bool {
    return assets.contains(asset)
  }
}
