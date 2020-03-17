import UIKit

protocol PermissionControllerDelegate: class {
  func permissionControllerDidFinish(_ controller: PermissionController)
}

class PermissionController: UIViewController {

  lazy var permissionView: PermissionView = self.makePermissionView()

  weak var delegate: PermissionControllerDelegate?

  let once = Once()

  // MARK: - Life cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    setup()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    once.run {
      self.check()
    }
  }

  // MARK: - Setup

  func setup() {
    view.addSubview(permissionView)
    permissionView.isHidden = true
    permissionView.closeButton.addTarget(self, action: #selector(closeButtonTouched(_:)),
                                         for: .touchUpInside)
    permissionView.settingButton.addTarget(self, action: #selector(settingButtonTouched(_:)),
                                           for: .touchUpInside)

    permissionView.translatesAutoresizingMaskIntoConstraints = false
    permissionView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
    permissionView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
    permissionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
    permissionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
  }

  // MARK: - Logic

  func check() {
    if Permission.Photos.status == .notDetermined {
      Permission.Photos.request { [weak self] in
        self?.check()
      }

      return
    }

    if Permission.Camera.needsPermission && Permission.Camera.status == .notDetermined {
      Permission.Camera.request { [weak self] in
        self?.check()
      }

      return
    }

    DispatchQueue.main.async {
      self.permissionView.isHidden = false
      self.delegate?.permissionControllerDidFinish(self)
    }
  }

  // MARK: - Action

  @objc func settingButtonTouched(_ button: UIButton) {
    DispatchQueue.main.async {
      if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.openURL(settingsURL)
      }
    }
  }

  @objc func closeButtonTouched(_ button: UIButton) {
    EventHub.shared.close?()
  }

  // MARK: - Controls

  func makePermissionView() -> PermissionView {
    let view = PermissionView()

    return view
  }
}
