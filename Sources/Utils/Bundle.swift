import UIKit

class Bundle {

  static func image(named: String) -> UIImage? {
    let bundle = NSBundle(forClass: Bundle.self)
    return UIImage(named: "Gallery.bundle/\(named)", inBundle: bundle, compatibleWithTraitCollection: nil)
  }
}
