import UIKit
import Cartography

class VideoBox: UIView {

  lazy var imageView: UIImageView = self.makeImageView()
  lazy var cameraImageView: UIImageView = self.makeCameraImageView()

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
    backgroundColor = UIColor.clearColor()
    Utils.addRoundBorder(imageView)

    [imageView, cameraImageView].forEach {
      self.addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }

    constrain(imageView, cameraImageView) {
      imageView, cameraImageView in

      imageView.edges == imageView.superview!.edges

      cameraImageView.left == cameraImageView.superview!.left + 5
      cameraImageView.bottom == cameraImageView.superview!.bottom - 5
      cameraImageView.width == 12
      cameraImageView.height == 6
    }
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
