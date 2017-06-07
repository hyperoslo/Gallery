import UIKit

class PermissionView: UIView {

  lazy var imageView: UIImageView = self.makeImageView()
  lazy var label: UILabel = self.makeLabel()
  lazy var settingButton: UIButton = self.makeSettingButton()
  lazy var closeButton: UIButton = self.makeCloseButton()

  // MARK: - Initialization

  override init(frame: CGRect) {
    super.init(frame: frame)

    backgroundColor = UIColor.white
    setup()

  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Setup

  func setup() {
    [label, settingButton, closeButton, imageView].forEach {
      addSubview($0)
    }

    closeButton.g_pin(on: .top)
    closeButton.g_pin(on: .left)
    closeButton.g_pin(size: CGSize(width: 44, height: 44))

    settingButton.g_pinCenter()
    settingButton.g_pin(height: 44)

    label.g_pin(on: .bottom, view: settingButton, on: .top, constant: -33)
    label.g_pinHorizontally(padding: 50)
    label.g_pin(greaterThanHeight: 200)

    imageView.g_pinCenter()
    imageView.g_pin(on: .bottom, view: label, on: .top, constant: -12)
  }

  // MARK: - Controls

  func makeLabel() -> UILabel {
    let label = UILabel()
    label.textColor = Config.Permission.textColor
    label.font = Config.Font.Text.regular.withSize(14)
    if !Permission.Camera.needsPermission && Permission.Photos.needsPermission {
      label.text = "Gallery.Permission.Info".g_localize(fallback: "Please grant access to photos.")
    } else if Permission.Camera.needsPermission && !Permission.Photos.needsPermission {
      label.text = "Camera.Permission.Info".g_localize(fallback: "Please grant access to the camera.")
    } else {
      label.text = "GalleryAndCamera.Permission.Info".g_localize(fallback: "Please grant access to photos and the camera.")
    }
    label.textAlignment = .center
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping

    return label
  }

  func makeSettingButton() -> UIButton {
    let button = UIButton(type: .custom)
    button.setTitle("Gallery.Permission.Button".g_localize(fallback: "Go to Settings").uppercased(),
                    for: UIControlState())
    button.backgroundColor = Config.Permission.Button.backgroundColor
    button.titleLabel?.font = Config.Font.Main.medium.withSize(16)
    button.setTitleColor(Config.Permission.Button.textColor, for: UIControlState())
    button.setTitleColor(Config.Permission.Button.highlightedTextColor, for: .highlighted)
    button.layer.cornerRadius = 22
    button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

    return button
  }

  func makeCloseButton() -> UIButton {
    let button = UIButton(type: .custom)
    button.setImage(Bundle.image("gallery_close")?.withRenderingMode(.alwaysTemplate), for: UIControlState())
    button.tintColor = Config.Grid.CloseButton.tintColor

    return button
  }

  func makeImageView() -> UIImageView {
    let view = UIImageView()
    view.image = Config.Permission.image

    return view
  }
}
