import UIKit
import Cartography

class ImageCell: UICollectionViewCell {

  lazy var imageView: UIImageView = self.makeImageView()
  lazy var overlay: UIView = self.makeOverlay()

  // MARK: - Initialization

  override init(frame: CGRect) {
    super.init(frame: frame)

    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Highlight

  override var highlighted: Bool {
    didSet {
      overlay.hidden = !highlighted
    }
  }

  // MARK: - Setup

  func setup() {
    [imageView, overlay].forEach {
      self.contentView.addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }

    constrain(imageView, overlay) {
      imageView, overlay in

      imageView.edges == imageView.superview!.edges
      overlay.edges == overlay.superview!.edges
    }
  }

  // MARK: - Controls

  func makeImageView() -> UIImageView {
    let imageView = UIImageView()
    imageView.clipsToBounds = true
    imageView.contentMode = .ScaleAspectFill

    return imageView
  }

  func makeOverlay() -> UIView {
    let view = UIView()
    view.userInteractionEnabled = false
    view.backgroundColor = UIColor.purpleColor().colorWithAlphaComponent(0.3)
    view.hidden = true

    return view
  }
}
