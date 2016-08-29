import UIKit
import Cartography
import Photos

class ImageCell: UICollectionViewCell {

  lazy var imageView: UIImageView = self.makeImageView()
  lazy var overlay: UIView = self.makeOverlay()
  lazy var frameView: FrameView = self.makeFrameView()

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

  // MARK: - Config

  func configure(asset: PHAsset) {
    Fetcher.resolveAsset(asset) { image in
      self.imageView.image = image
    }
  }

  // MARK: - Setup

  func setup() {
    [imageView, frameView, overlay].forEach {
      self.contentView.addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }

    constrain(imageView, frameView, overlay) {
      imageView, frameView, overlay in

      imageView.edges == imageView.superview!.edges
      frameView.edges == frameView.superview!.edges
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
    view.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.3)
    view.hidden = true

    return view
  }

  func makeFrameView() -> FrameView {
    let frameView = FrameView(frame: .zero)
    frameView.hidden = true

    return frameView
  }
}
