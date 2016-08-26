import UIKit

class ArrowButton: UIButton {

  lazy var label: UILabel = self.makeLabel()
  lazy var arrow: UIImageView = self.makeArrow()

  let padding: CGFloat = 10
  let arrowSize: CGFloat = 8

  // MARK: - Initialization

  init() {
    super.init(frame: CGRect.zero)

    addSubview(label)
    addSubview(arrow)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    label.center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)

    arrow.frame.size = CGSize(width: arrowSize, height: arrowSize)
    arrow.center = CGPoint(x: label.frame.maxX + padding, y: bounds.size.height / 2)
  }


  override func intrinsicContentSize() -> CGSize {
    let size = super.intrinsicContentSize()
    label.sizeToFit()

    return CGSize(width: label.frame.size.width + arrowSize*2 + padding,
                  height: size.height)
  }

  // MARK: - Logic

  func toggle() {
    let transform = CGAffineTransformEqualToTransform(arrow.transform, CGAffineTransformIdentity)
      ? CGAffineTransformMakeRotation(CGFloat(M_PI)) : CGAffineTransformIdentity
    
    UIView.animateWithDuration(0.25) {
      self.arrow.transform = transform
    }
  }

  // MARK: - Controls

  func makeLabel() -> UILabel {
    let label = UILabel()
    label.textColor = Config.Grid.ArrowButton.tintColor
    label.font = UIFont.systemFontOfSize(16)
    label.textAlignment = .Center

    return label
  }

  func makeArrow() -> UIImageView {
    let arrow = UIImageView()
    arrow.image = BundleAsset.image("gallery_title_arrow")?.imageWithRenderingMode(.AlwaysTemplate)
    arrow.tintColor = Config.Grid.ArrowButton.tintColor

    return arrow
  }

  // MARK: - Touch

  override var highlighted: Bool {
    didSet {
      label.textColor = highlighted ? UIColor.lightGrayColor() : Config.Grid.ArrowButton.tintColor
      arrow.tintColor = highlighted ? UIColor.lightGrayColor() : Config.Grid.ArrowButton.tintColor
    }
  }
}
