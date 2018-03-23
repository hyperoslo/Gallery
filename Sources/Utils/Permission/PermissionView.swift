import UIKit

class PermissionView: UIView {

  lazy var mainLabel: UILabel = self.makeMainLabel()
  lazy var detailLabel: UILabel = self.makeDetailLabel()
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
    [mainLabel, detailLabel, settingButton, closeButton].forEach {
      addSubview($0)
    }

    closeButton.g_pin(on: .top)
    closeButton.g_pin(on: .left)
    closeButton.g_pin(size: CGSize(width: 44, height: 44))

    mainLabel.g_pin(on: .left, constant: 12)
    mainLabel.g_pin(on: .right, constant: -12)
    
    detailLabel.g_pinCenter()
    detailLabel.g_pin(on: .left, constant: 12)
    detailLabel.g_pin(on: .right, constant: -12)
    detailLabel.g_pin(on: .top, view: mainLabel, on: .bottom, constant: 12)
    
    settingButton.g_pin(on: .centerX)
    settingButton.g_pin(on: .top, view: detailLabel, on: .bottom, constant: 12)
  }

  // MARK: - Controls

  func makeMainLabel() -> UILabel {
    let label = UILabel()
    label.textColor = Config.Permission.MainLabel.textColor
    label.font = Config.Permission.MainLabel.font
    label.text = Config.Permission.MainLabel.text
    label.textAlignment = .center
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping

    return label
  }
    
  func makeDetailLabel() -> UILabel {
    let label = UILabel()
    label.textColor = Config.Permission.DetailLabel.textColor
    label.font = Config.Permission.DetailLabel.font
    label.text = Config.Permission.DetailLabel.text
    label.textAlignment = .center
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
        
    return label
  }

  func makeSettingButton() -> UIButton {
    let button = UIButton(type: .system)
    button.setTitle(Config.Permission.SettingButton.text, for: UIControlState())
    button.setTitleColor(Config.Permission.SettingButton.textColor, for: UIControlState())
    button.backgroundColor = Config.Permission.SettingButton.backgroundColor
    button.titleLabel?.font = Config.Permission.SettingButton.font

    return button
  }

  func makeCloseButton() -> UIButton {
    let button = UIButton(type: .custom)
    button.setImage(GalleryBundle.image("gallery_close")?.withRenderingMode(.alwaysTemplate), for: UIControlState())
    button.tintColor = Config.Grid.CloseButton.tintColor

    return button
  }

}
