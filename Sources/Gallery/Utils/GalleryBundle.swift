import UIKit

class GalleryBundle {

  static func image(_ named: String) -> UIImage? {
    let bundle = Bundle.module
    return UIImage(named: "Gallery.bundle/\(named)", in: bundle, compatibleWith: nil)
  }
}
