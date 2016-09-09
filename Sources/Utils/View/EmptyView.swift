import UIKit
import Cartography

class EmptyView: UIView {

  lazy var imageView: UIImageView = self.makeImageView()
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
    [label, imageView].forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
      addSubview($0)
    }

    constrain(imageView, label) {
      imageView, label in

      label.center == label.superview!.center

      imageView.centerX == imageView.superview!.centerX
      imageView.bottom == label.top - 12
    }
  }

  // MARK: - Controls

  func makeLabel() -> UILabel {
    let label = UILabel()
    label.textColor = Config.EmptyView.textColor
    label.font = Config.Font.Text.regular.fontWithSize(14)
    label.text = "Gallery.EmptyView.Text".g_localize(fallback: "Nothing to show")

    return label
  }

  func makeImageView() -> UIImageView {
    let view = UIImageView()
    view.image = Config.EmptyView.image

    return view
  }
}
