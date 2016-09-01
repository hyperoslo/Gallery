import UIKit
import Cartography
import Photos

extension UIViewController {

  func addChildController(controller: UIViewController) {
    addChildViewController(controller)
    view.addSubview(controller.view)
    controller.didMoveToParentViewController(self)

    controller.view.translatesAutoresizingMaskIntoConstraints = false

    constrain(controller.view) { view in
      view.edges == view.superview!.edges
    }
  }
}

extension UIView {

  func addShadow() {
    layer.shadowColor = UIColor.blackColor().CGColor
    layer.shadowOpacity = 0.5
    layer.shadowOffset = CGSize(width: 0, height: 1)
    layer.shadowRadius = 1
  }

  func addRoundBorder() {
    layer.borderWidth = 1
    layer.borderColor = Config.Grid.FrameView.borderColor.CGColor
    layer.cornerRadius = 3
    clipsToBounds = true
  }

  func fadeIn() {
    UIView.animateWithDuration(0.25) {
      self.alpha = 1.0
    }
  }
}

extension UIScrollView {

  func scrollToTop() {
    setContentOffset(CGPoint.zero, animated: false)
  }
}

extension UIImageView {

  func loadImage(asset: PHAsset) {
    guard frame.size != CGSize.zero
      else {
      image = Bundle.image("gallery_placeholder")
      return
    }

    if tag == 0 {
      image = Bundle.image("gallery_placeholder")
    } else {
      PHImageManager.defaultManager().cancelImageRequest(PHImageRequestID(tag))
    }

    let options = PHImageRequestOptions()

    let id = PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: frame.size,
                                                         contentMode: .AspectFill, options: options)
    { [weak self] image, _ in

      self?.image = image
    }

    tag = Int(id)
  }
}

extension Array {

  mutating func moveToFirst(index: Int) {
    guard index != 0 && index < count else { return }

    let item = self[index]
    removeAtIndex(index)
    insert(item, atIndex: 0)
  }
}