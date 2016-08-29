import UIKit
import Cartography

class ImageCell: UICollectionViewCell {

  lazy var imageView: UIImageView = self.makeImageView()

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
    contentView.addSubview(imageView)
    imageView.translatesAutoresizingMaskIntoConstraints = false

    constrain(imageView) {
      imageView in

      imageView.edges == imageView.superview!.edges
    }
  }

  // MARK: - Controls

  func makeImageView() -> UIImageView {
    let imageView = UIImageView()
    imageView.clipsToBounds = true
    imageView.contentMode = .ScaleAspectFill

    return imageView
  }
}
