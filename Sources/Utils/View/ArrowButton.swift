import UIKit

class ArrowButton: UIButton {

  lazy var label: UILabel = self.makeLabel()
  lazy var arrow: UIImageView = self.makeArrow()

    let padding: CGFloat = 12
    let arrowSize: CGFloat = 11
    let arrowHeight: CGFloat = 8

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

    arrow.frame.size = CGSize(width: arrowSize, height: arrowHeight)
    arrow.center = CGPoint(x: label.frame.maxX + padding, y: bounds.size.height / 2)
  }


  override var intrinsicContentSize : CGSize {
    let size = super.intrinsicContentSize
    label.sizeToFit()

    return CGSize(width: label.frame.size.width + arrowSize*2 + padding,
                  height: size.height)
  }

  // MARK: - Logic

  func updateText(_ text: String) {
    label.text = text
    arrow.alpha = text.isEmpty ? 0 : 1
    invalidateIntrinsicContentSize()
  }

  func toggle(_ expanding: Bool) {
    let transform = expanding
      ? CGAffineTransform(rotationAngle: CGFloat(Double.pi)) : CGAffineTransform.identity
    
    UIView.animate(withDuration: 0.25, animations: {
      self.arrow.transform = transform
    }) 
  }

  // MARK: - Controls

  private func makeLabel() -> UILabel {
    let label = UILabel()
    if let font = GalleryConfig.shared.selectedAlbumFont {
       label.font = font
    }
    let color = GalleryConfig.shared.selectedAlbumColor ?? .white
       label.textColor = color
    label.textAlignment = .center
    return label
  }

  private func makeArrow() -> UIImageView {
    let arrow = UIImageView()
    arrow.image = GalleryBundle.image("arrow")?.withRenderingMode(.alwaysTemplate)
    arrow.tintColor = UIColor.white
    arrow.alpha = 0
    return arrow
  }

  // MARK: - Touch

  override var isHighlighted: Bool {
    didSet {
        let color = GalleryConfig.shared.selectedAlbumColor ?? .white
            label.textColor = isHighlighted ? UIColor.lightGray : color
            arrow.tintColor = isHighlighted ? UIColor.lightGray : color
    }
  }
}
