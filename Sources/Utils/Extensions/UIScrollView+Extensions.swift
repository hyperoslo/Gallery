import UIKit

extension UIScrollView {

  func g_scrollToTop() {
    setContentOffset(CGPoint.zero, animated: false)
  }
}
