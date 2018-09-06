import UIKit

extension UIViewController {

  func g_addChildController(_ controller: UIViewController) {
    addChildViewController(controller)
    view.addSubview(controller.view)
    controller.didMove(toParentViewController: self)

    controller.view.g_pinEdges()
  }

  func g_removeFromParentController() {
    willMove(toParentViewController: nil)
    view.removeFromSuperview()
    removeFromParentViewController()
  }
}
