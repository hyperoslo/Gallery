import UIKit

class BundleAsset {

  static func image(named: String) -> UIImage? {
    let bundle = NSBundle(forClass: BundleAsset.self)
    return UIImage(named: "Photos.bundle/\(named)", inBundle: bundle, compatibleWithTraitCollection: nil)
  }
}
