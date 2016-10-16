import UIKit

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
      addSubview($0 as! UIView)
    }

    label.g_pinCenter()
    imageView.g_pin(on: .centerX)
    imageView.g_pin(on: .bottom, view: label, on: .top, constant: -12)
  }

  // MARK: - Controls

  func makeLabel() -> UILabel {
    let label = UILabel()
    label.textColor = Config.EmptyView.textColor
    label.font = Config.Font.Text.regular.withSize(14)
    label.text = "Gallery.EmptyView.Text".g_localize(fallback: "Nothing to show")

    return label
  }

  func makeImageView() -> UIImageView {
    let view = UIImageView()
    view.image = Config.EmptyView.image

    return view
  }
}
