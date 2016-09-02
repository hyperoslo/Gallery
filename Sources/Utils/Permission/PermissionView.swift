import UIKit
import Cartography

class PermissionView: UIView {

  lazy var label: UILabel = self.makeLabel()
  lazy var settingButton: UIButton = self.makeSettingButton()
  lazy var closeButton: UIButton = self.makeCloseButton()

  // MARK: - Initialization

  override init(frame: CGRect) {
    super.init(frame: frame)

    backgroundColor = UIColor.whiteColor()
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Setup

  func setup() {
    [label, settingButton, closeButton].forEach {
      addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }

    constrain(closeButton, label, settingButton) {
      closeButton, label, settingButton in

      closeButton.top == closeButton.superview!.top
      closeButton.left == closeButton.superview!.left
      closeButton.width == 44
      closeButton.height == 44

      label.centerY == label.superview!.centerY
      label.left == label.superview!.left + 50
      label.right == label.superview!.right - 50

      settingButton.top == label.bottom + 30
      settingButton.centerX == settingButton.superview!.centerX
    }
  }

  // MARK: - Controls

  func makeLabel() -> UILabel {
    let label = UILabel()
    label.textColor = UIColor.blackColor()
    label.font = Config.Font.Text.regular.fontWithSize(20)
    label.text = "Please enable Photos and Camera"
    label.textAlignment = .Center
    label.numberOfLines = 0

    return label
  }

  func makeSettingButton() -> UIButton {
    let button = UIButton(type: .System)
    button.setTitle("Go to Settings", forState: .Normal)

    return button
  }

  func makeCloseButton() -> UIButton {
    let button = UIButton(type: .Custom)
    button.setImage(Bundle.image("gallery_close")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
    button.tintColor = Config.Grid.CloseButton.tintColor

    return button
  }
}
