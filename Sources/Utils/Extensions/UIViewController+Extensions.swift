import UIKit

extension UIViewController {

  func g_addChildController(_ controller: UIViewController) {
    addChild(controller)
    view.addSubview(controller.view)
    controller.didMove(toParent: self)

    controller.view.g_pinEdges()
  }

  func g_removeFromParentController() {
    willMove(toParent: nil)
    view.removeFromSuperview()
    removeFromParent()
  }
}
