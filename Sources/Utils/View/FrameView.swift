import UIKit
import Cartography

class FrameView: UIView {

  lazy var label: UILabel = self.makeLabel()

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
    layer.backgroundColor = Config.Grid.FrameView.fillColor.CGColor
    layer.borderColor = Config.Grid.FrameView.borderColor.CGColor
    layer.borderWidth = 3

    addSubview(label)
    label.translatesAutoresizingMaskIntoConstraints = false

    constrain(label) {
      label in

      label.center == label.superview!.center
    }
  }

  // MARK: - Controls

  func makeLabel() -> UILabel {
    let label = UILabel()
    label.font = Config.Font.Main.regular.fontWithSize(40)
    label.textColor = UIColor.whiteColor()

    return label
  }
}
