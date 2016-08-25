import UIKit
import Cartography

class CameraView: UIView {

  lazy var closeButton: UIButton = self.makeCloseButton()
  lazy var flashButton: TripleButton = self.makeFlashButton()
  lazy var rotateButton: UIButton = self.makeRotateButton()
  lazy var bottomContainer: UIView = self.makeBottomContainer()
  lazy var stackView: StackView = self.makeStackView()
  lazy var shutterButton: ShutterButton = self.makeShutterButton()
  lazy var doneButton: UIButton = self.makeDoneButton()

  // MARK: - Initialization

  override init(frame: CGRect) {
    super.init(frame: frame)

    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Setup

  func setup() {

  }

  // MARK: - Controls

  func makeCloseButton() -> UIButton {
    let button = UIButton(type: .Custom)
    button.setImage(BundleAsset.image("gallery_close"), forState: .Normal)

    return button
  }

  func makeFlashButton() -> TripleButton {
    let button = TripleButton()

    return button
  }

  func makeRotateButton() -> UIButton {
    let button = UIButton(type: .Custom)
    button.setImage(BundleAsset.image("gallery_camera_rotate"), forState: .Normal)

    return button
  }

  func makeBottomContainer() -> UIView {
    let view = UIView()
    view.backgroundColor = UIColor(red: 3/255, green: 15/255, blue: 29/255, alpha: 0.7)

    return view
  }

  func makeStackView() -> StackView {
    let view = StackView()

    return view
  }

  func makeShutterButton() -> ShutterButton {
    let button = ShutterButton()

    return button
  }

  func makeDoneButton() -> UIButton {
    let button = UIButton(type: .System)
    button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    button.titleLabel?.font = UIFont.systemFontOfSize(16)
    button.setTitle("Done", forState: .Normal)

    return button
  }

}
