import UIKit
import Cartography

class CameraController: UIViewController {

  lazy var cameraView: CameraView = self.makeCameraView()

  // MARK: - Life cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    setup()
  }

  // MARK: - Setup

  func setup() {
    view.addSubview(cameraView)

    cameraView.translatesAutoresizingMaskIntoConstraints = false

    constrain(cameraView) { cameraView in
      cameraView.edges == cameraView.superview!.edges
    }
  }

  // MARK: - Controls

  func makeCameraView() -> CameraView {
    let cameraView = CameraView()

    return cameraView
  }
}
