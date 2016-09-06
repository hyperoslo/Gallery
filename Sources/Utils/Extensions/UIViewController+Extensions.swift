import UIKit
import Cartography

extension UIViewController {

  func g_addChildController(controller: UIViewController) {
    addChildViewController(controller)
    view.addSubview(controller.view)
    controller.didMoveToParentViewController(self)

    controller.view.translatesAutoresizingMaskIntoConstraints = false

    constrain(controller.view) { view in
      view.edges == view.superview!.edges
    }
  }

  func g_removeFromParentController() {
    willMoveToParentViewController(nil)
    view.removeFromSuperview()
    removeFromParentViewController()
  }
}