import UIKit
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

  override var isHighlighted: Bool {
    didSet {
      highlightOverlay.isHidden = !isHighlighted
    }
  }

  // MARK: - Config

  func configure(_ asset: PHAsset) {
    imageView.layoutIfNeeded()
    imageView.g_loadImage(asset)
  }

  func configure(_ image: Image) {
    configure(image.asset)
  }

  // MARK: - Setup

  func setup() {
    [imageView, frameView, highlightOverlay].forEach {
      self.contentView.addSubview($0)
    }

    imageView.g_pinEdges()
    frameView.g_pinEdges()
    highlightOverlay.g_pinEdges()
  }

  // MARK: - Controls

  private func makeImageView() -> UIImageView {
    let imageView = UIImageView()
    imageView.clipsToBounds = true
    imageView.contentMode = .scaleAspectFill

    return imageView
  }

  private func makeHighlightOverlay() -> UIView {
    let view = UIView()
    view.isUserInteractionEnabled = false
    view.backgroundColor = Config.Grid.FrameView.borderColor.withAlphaComponent(0.3)
    view.isHidden = true

    return view
  }

  private func makeFrameView() -> FrameView {
    let frameView = FrameView(frame: .zero)
    frameView.alpha = 0

    return frameView
  }
}
