import UIKit

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

  private func setup() {
    layer.addSublayer(gradientLayer)
    // TODO: Update frameview color
    layer.borderColor = UIColor.white.cgColor
    layer.borderWidth = 3

    addSubview(label)
    label.g_pinCenter()
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    gradientLayer.frame = bounds
  }

  // MARK: - Controls

  private func makeLabel() -> UILabel {
    let label = UILabel()
    label.font = Config.Font.Main.regular.withSize(40)
    label.textColor = UIColor.white

    return label
  }

  private func makeGradientLayer() -> CAGradientLayer {
    let layer = CAGradientLayer()
    layer.colors = [
      Config.Grid.FrameView.fillColor.withAlphaComponent(0.25).cgColor,
      Config.Grid.FrameView.fillColor.withAlphaComponent(0.4).cgColor
    ]

    return layer
  }
}
