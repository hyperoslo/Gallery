import UIKit
import Cartography

class PermissionView: UIView {

  lazy var imageView: UIImageView = self.makeImageView()
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
    [label, settingButton, closeButton, imageView].forEach {
      addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }

    constrain(closeButton, label, settingButton, imageView) {
      closeButton, label, settingButton, imageView in

      closeButton.top == closeButton.superview!.top
      closeButton.left == closeButton.superview!.left
      closeButton.height == 44
      closeButton.width == 44

      settingButton.center == settingButton.superview!.center
      settingButton.height == 44

      label.bottom == settingButton.top - 33
      label.left == label.superview!.left + 50
      label.right == label.superview!.right - 50

      imageView.centerX == imageView.superview!.centerX
      imageView.bottom == label.top - 12
    }
  }

  // MARK: - Controls

  func makeLabel() -> UILabel {
    let label = UILabel()
    label.textColor = Config.Permission.textColor
    label.font = Config.Font.Text.regular.fontWithSize(14)
    label.text = "Gallery.Permission.Info".g_localize(fallback: "Please enable photos and camera")
    label.textAlignment = .Center
    label.numberOfLines = 0

    return label
  }

  func makeSettingButton() -> UIButton {
    let button = UIButton(type: .Custom)
    button.setTitle("Gallery.Permission.Button".g_localize(fallback: "Go to Settings").uppercaseString,
                    forState: .Normal)
    button.backgroundColor = Config.Permission.buttonBackgroundColor
    button.titleLabel?.font = Config.Font.Main.medium.fontWithSize(16)
    button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    button.layer.cornerRadius = 22
    button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

    return button
  }

  func makeCloseButton() -> UIButton {
    let button = UIButton(type: .Custom)
    button.setImage(Bundle.image("gallery_close")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
    button.tintColor = Config.Grid.CloseButton.tintColor

    return button
  }

  func makeImageView() -> UIImageView {
    let view = UIImageView()
    view.image = Config.Permission.image

    return view
  }
}
