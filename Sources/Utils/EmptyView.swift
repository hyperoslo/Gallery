import UIKit
import Cartography

class EmptyView: UIView {

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
    label.textColor = UIColor.blackColor()
    label.font = Config.Font.Text.regular.fontWithSize(15)
    label.text = "Nothing to show"

    return label
  }
}
