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

    cameraView.closeButton.addTarget(self, action: #selector(closeButtonTouched(_:)), forControlEvents: .TouchUpInside)
    cameraView.flashButton.addTarget(self, action: #selector(flashButtonTouched(_:)), forControlEvents: .TouchUpInside)
    cameraView.rotateButton.addTarget(self, action: #selector(rotateButtonTouched(_:)), forControlEvents: .TouchUpInside)
    cameraView.stackView.addTarget(self, action: #selector(stackViewTouched(_:)), forControlEvents: .TouchUpInside)
    cameraView.shutterButton.addTarget(self, action: #selector(shutterButtonTouched(_:)), forControlEvents: .TouchUpInside)
    cameraView.doneButton.addTarget(self, action: #selector(doneButtonTouched(_:)), forControlEvents: .TouchUpInside)
  }

  // MARK: - Action

  func closeButtonTouched(button: UIButton) {

  }

  func flashButtonTouched(button: UIButton) {

  }

  func rotateButtonTouched(button: UIButton) {

  }

  func stackViewTouched(stackView: StackView) {

  }

  func shutterButtonTouched(button: ShutterButton) {

  }

  func doneButtonTouched(button: UIButton) {

  }

  // MARK: - Controls

  func makeCameraView() -> CameraView {
    let cameraView = CameraView()

    return cameraView
  }
}
