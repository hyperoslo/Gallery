import UIKit
import Cartography
import Photos

class VideoCell: ImageCell {

  lazy var cameraImageView: UIImageView = self.makeCameraImageView()
  lazy var durationLabel: UILabel = self.makeDurationLabel()
  lazy var bottomOverlay: UIView = self.makeBottomOverlay()

  // MARK: - Config

  func configure(video: Video) {
    super.configure(video.asset)

    video.fetchDuration { duration in
      self.durationLabel.text = "\(Utils.format(duration))"
    }
  }

  // MARK: - Setup

  override func setup() {
    super.setup()

    [bottomOverlay, cameraImageView, durationLabel].forEach {
      self.insertSubview($0, belowSubview: self.highlightOverlay)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }

    constrain(bottomOverlay, cameraImageView, durationLabel) {
      bottomOverlay, cameraImageView, durationLabel in

      bottomOverlay.left == bottomOverlay.superview!.left
      bottomOverlay.right == bottomOverlay.superview!.right
      bottomOverlay.bottom == bottomOverlay.superview!.bottom
      bottomOverlay.height == 16

      cameraImageView.left == cameraImageView.superview!.left + 5
      cameraImageView.bottom == cameraImageView.superview!.bottom - 5
      cameraImageView.width == 12
      cameraImageView.height == 6

      durationLabel.right == durationLabel.superview!.right - 4
      durationLabel.bottom == durationLabel.superview!.bottom - 2
    }
  }

  // MARK: - Controls

  func makeCameraImageView() -> UIImageView {
    let imageView = UIImageView()
    imageView.image = Bundle.image("gallery_video_cell_camera")

    return imageView
  }

  func makeDurationLabel() -> UILabel {
    let label = UILabel()
    label.font = UIFont.boldSystemFontOfSize(9)
    label.textColor = UIColor.whiteColor()
    label.textAlignment = .Right

    return label
  }

  func makeBottomOverlay() -> UIView {
    let view = UIView()
    view.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)

    return view
  }
}
