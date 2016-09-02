import UIKit
import Cartography

protocol PermissionControllerDelegate: class {
  func permissionControllerDidFinish(controller: PermissionController)
}

class PermissionController: UIViewController {

  lazy var permissionView: PermissionView = self.makePermissionView()

  weak var delegate: PermissionControllerDelegate?

  // MARK: - Life cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    setup()
  }

  // MARK: - Setup

  func setup() {
    view.addSubview(permissionView)
    permissionView.translatesAutoresizingMaskIntoConstraints = false

    permissionView.closeButton.addTarget(self, action: #selector(closeButtonTouched(_:)),
                                         forControlEvents: .TouchUpInside)
    permissionView.settingButton.addTarget(self, action: #selector(settingButtonTouched(_:)),
                                           forControlEvents: .TouchUpOutside)

    constrain(permissionView) {
      permissionView in

      permissionView.edges == permissionView.superview!.edges
    }
  }

  // MARK: - Action

  func settingButtonTouched(button: UIButton) {
    Dispatch.main {
      if let settingsURL = NSURL(string: UIApplicationOpenSettingsURLString) {
        UIApplication.sharedApplication().openURL(settingsURL)
      }
    }
  }

  func closeButtonTouched(button: UIButton) {
    EventHub.shared.close?()
  }

  // MARK: - Controls

  func makePermissionView() -> PermissionView {
    let view = PermissionView()

    return view
  }
}
