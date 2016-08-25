import UIKit
import Cartography

class ShutterButton: UIButton {

  lazy var numberLabel: UILabel = self.makeNumberLabel()
  lazy var roundLayer: CAShapeLayer = self.makeRoundLayer()

  // MARK: - Initialization

  override init(frame: CGRect) {
    super.init(frame: frame)

    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    roundLayer.path = UIBezierPath(ovalInRect: CGRectInset(bounds, 3, 3)).CGPath
    layer.cornerRadius = bounds.size.width/2
  }

  // MARK: - Setup

  func setup() {
    backgroundColor = UIColor.whiteColor()

    layer.addSublayer(roundLayer)

    addSubview(numberLabel)
    numberLabel.translatesAutoresizingMaskIntoConstraints = false

    constrain(numberLabel) { numberLabel in
      numberLabel.center == numberLabel.superview!.center
    }
  }

  // MARK: - Controls

  func makeNumberLabel() -> UILabel {
    let label = UILabel()
    label.textColor = Config.Camera.ShutterButton.numberColor
    label.font = UIFont.boldSystemFontOfSize(16)
    label.text = "0"

    return label
  }

  func makeRoundLayer() -> CAShapeLayer {
    let layer = CAShapeLayer()
    layer.strokeColor = Config.Camera.ShutterButton.numberColor.CGColor
    layer.lineWidth = 2
    layer.fillColor = nil

    return layer
  }
}
