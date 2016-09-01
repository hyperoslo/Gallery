import UIKit
import Cartography

class ShutterButton: UIButton {

  lazy var overlayView: UIView = self.makeOverlayView()
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
  }

  // MARK: - Controls

  func makeOverlayView() -> UIView {
    let view = UIView()
    view.backgroundColor = UIColor.whiteColor()
    view.userInteractionEnabled = false

    return view
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
