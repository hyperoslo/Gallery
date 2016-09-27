import UIKit
import Cartography

class FrameView: UIView {

  lazy var label: UILabel = self.makeLabel()
  lazy var gradientLayer: CAGradientLayer = self.makeGradientLayer()

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
    layer.addSublayer(gradientLayer)
    layer.borderColor = Config.Grid.FrameView.borderColor.CGColor
    layer.borderWidth = 3

    addSubview(label)
    label.translatesAutoresizingMaskIntoConstraints = false

    constrain(label) {
      label in

      label.center == label.superview!.center
    }
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    gradientLayer.frame = bounds
  }

  // MARK: - Controls

  func makeLabel() -> UILabel {
    let label = UILabel()
    label.font = Config.Font.Main.regular.fontWithSize(40)
    label.textColor = UIColor.whiteColor()

    return label
  }

  func makeGradientLayer() -> CAGradientLayer {
    let layer = CAGradientLayer()
    layer.colors = [
      Config.Grid.FrameView.fillColor.colorWithAlphaComponent(0.25).CGColor,
      Config.Grid.FrameView.fillColor.colorWithAlphaComponent(0.4).CGColor
    ]

    return layer
  }
}
