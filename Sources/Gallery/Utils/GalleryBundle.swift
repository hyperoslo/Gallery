import UIKit

class GalleryBundle {

  static func image(_ named: String) -> UIImage? {
    let bundle = Foundation.Bundle(for: GalleryBundle.self)
    return UIImage(named: "Gallery.bundle/\(named)", in: bundle, compatibleWith: nil)
  }
}
