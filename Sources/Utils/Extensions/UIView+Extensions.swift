import UIKit

extension UIView {

  func g_addShadow() {
    layer.shadowColor = UIColor.blackColor().CGColor
    layer.shadowOpacity = 0.5
    layer.shadowOffset = CGSize(width: 0, height: 1)
    layer.shadowRadius = 1
  }

  func g_addRoundBorder() {
    layer.borderWidth = 1
    layer.borderColor = Config.Grid.FrameView.borderColor.CGColor
    layer.cornerRadius = 3
    clipsToBounds = true
  }

  func g_show() {
    UIView.animateWithDuration(0.1) {
      self.alpha = 1.0
    }
  }

  func g_fade(visible visible: Bool) {
    UIView.animateWithDuration(0.25) {
      self.alpha = visible ? 1 : 0
    }
  }
}
