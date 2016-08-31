import UIKit
import Cartography

class ShutterButton: UIButton {

  lazy var overlayView: UIView = self.makeOverlayView()
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

    overlayView.frame = CGRectInset(bounds, 3, 3)
    overlayView.layer.cornerRadius = overlayView.frame.size.width/2

    roundLayer.path = UIBezierPath(ovalInRect: CGRectInset(bounds, 3, 3)).CGPath
    layer.cornerRadius = bounds.size.width/2
  }

  // MARK: - Setup

  func setup() {
    backgroundColor = UIColor.whiteColor()

    addSubview(overlayView)
    layer.addSublayer(roundLayer)

    addSubview(numberLabel)
    numberLabel.translatesAutoresizingMaskIntoConstraints = false

    constrain(numberLabel) { numberLabel in
      numberLabel.center == numberLabel.superview!.center
    }
  }

  // MARK: - Controls

  func makeOverlayView() -> UIView {
    let view = UIView()
    view.backgroundColor = UIColor.whiteColor()
    view.userInteractionEnabled = false

    return view
  }

  func makeNumberLabel() -> UILabel {
    let label = UILabel()
    label.textColor = Config.Camera.ShutterButton.numberColor
    label.font = UIFont.boldSystemFontOfSize(16)

    return label
  }

  func makeRoundLayer() -> CAShapeLayer {
    let layer = CAShapeLayer()
    layer.strokeColor = Config.Camera.ShutterButton.numberColor.CGColor
    layer.lineWidth = 2
    layer.fillColor = nil

    return layer
  }

  // MARK: - Highlight

  override var highlighted: Bool {
    didSet {
      overlayView.backgroundColor = highlighted ? UIColor.grayColor() : UIColor.whiteColor()
    }
  }
}
