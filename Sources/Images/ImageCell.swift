import UIKit
import Cartography
import Photos

class ImageCell: UICollectionViewCell {

  lazy var imageView: UIImageView = self.makeImageView()
  lazy var highlightOverlay: UIView = self.makeHighlightOverlay()
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
      highlightOverlay.hidden = !highlighted
    }
  }

  // MARK: - Config

  func configure(asset: PHAsset) {
    imageView.layoutIfNeeded()
    imageView.g_loadImage(asset)
  }

  func configure(image: Image) {
    configure(image.asset)
  }

  // MARK: - Setup

  func setup() {
    [imageView, frameView, highlightOverlay].forEach {
      self.contentView.addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }

    constrain(imageView, frameView, highlightOverlay) {
      imageView, frameView, highlightOverlay in

      imageView.edges == imageView.superview!.edges
      frameView.edges == frameView.superview!.edges
      highlightOverlay.edges == highlightOverlay.superview!.edges
    }
  }

  // MARK: - Controls

  func makeImageView() -> UIImageView {
    let imageView = UIImageView()
    imageView.clipsToBounds = true
    imageView.contentMode = .ScaleAspectFill

    return imageView
  }

  func makeHighlightOverlay() -> UIView {
    let view = UIView()
    view.userInteractionEnabled = false
    view.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.3)
    view.hidden = true

    return view
  }

  func makeFrameView() -> FrameView {
    let frameView = FrameView(frame: .zero)
    frameView.alpha = 0

    return frameView
  }
}
