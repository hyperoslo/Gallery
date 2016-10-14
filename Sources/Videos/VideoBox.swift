import UIKit

protocol VideoBoxDelegate: class {
  func videoBoxDidTap(_ videoBox: VideoBox)
}

class VideoBox: UIView {

  lazy var imageView: UIImageView = self.makeImageView()
  lazy var cameraImageView: UIImageView = self.makeCameraImageView()

  weak var delegate: VideoBoxDelegate?

  // MARK: - Initialization

  override init(frame: CGRect) {
    super.init(frame: frame)

    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Action

  func viewTapped(_ gr: UITapGestureRecognizer) {
    delegate?.videoBoxDidTap(self)
  }

  // MARK: - Setup

  func setup() {
    backgroundColor = UIColor.clear
    imageView.g_addRoundBorder()

    let gr = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
    addGestureRecognizer(gr)

    [imageView, cameraImageView].forEach {
      self.addSubview($0)
    }

    imageView.g_pinEdges()
    cameraImageView.g_pin(on: .left, constant: 5)
    cameraImageView.g_pin(on: .bottom, constant: -5)
    cameraImageView.g_pin(size: CGSize(width: 12, height: 6))
  }

  // MARK: - Controls

  func makeImageView() -> UIImageView {
    let imageView = UIImageView()
    imageView.clipsToBounds = true

    return imageView
  }

  func makeCameraImageView() -> UIImageView {
    let imageView = UIImageView()
    imageView.image = Bundle.image("gallery_video_cell_camera")

    return imageView
  }
}
