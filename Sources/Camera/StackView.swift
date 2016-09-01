import UIKit
import Photos

class StackView: UIControl{

  lazy var indicator: UIActivityIndicatorView = self.makeIndicator()
  lazy var imageViews: [UIImageView] = self.makeImageViews()
  lazy var countLabel: UILabel = self.makeCountLabel()
  lazy var tapGR: UITapGestureRecognizer = self.makeTapGR()

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
    addGestureRecognizer(tapGR)
    imageViews.forEach {
      addSubview($0)
    }

    [countLabel, indicator].forEach {
      self.addSubview($0)
    }
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    let step: CGFloat = 3.0
    let scale: CGFloat = 0.8
    let imageViewSize = CGSize(width: frame.width * scale,
                          height: frame.height * scale)

    for (index, imageView) in imageViews.enumerate() {
      let origin = CGPoint(x: CGFloat(index) * step,
                           y: CGFloat(imageViews.count - index) * step)
      imageView.frame = CGRect(origin: origin, size: imageViewSize)
    }
  }

  // MARK: - Action

  func viewTapped(gr: UITapGestureRecognizer) {
    sendActionsForControlEvents(.TouchUpInside)
  }

  // MARK: - Logic

  func startLoading() {
    if let topVisibleView = imageViews.filter({ $0.alpha == 1.0 }).last {
      indicator.center = topVisibleView.center
    } else if let first = imageViews.first {
      indicator.center = first.center
    }

    indicator.startAnimating()
    UIView.animateWithDuration(0.3) {
      self.indicator.alpha = 1.0
    }
  }

  func stopLoading() {
    indicator.stopAnimating()
    indicator.alpha = 0
  }

  func renderViews(assets: [PHAsset]) {
    let photos = Array(assets.suffix(Config.Camera.StackView.imageCount))

    for (index, view) in imageViews.enumerate() {
      if index < photos.count {
        view.loadImage(photos[index])
        view.alpha = 1
      } else {
        view.image = nil
        view.alpha = 0
      }
    }
  }

  private func animate(imageView imageView: UIImageView) {
    imageView.transform = CGAffineTransformMakeScale(0, 0)

    UIView.animateKeyframesWithDuration(0.5, delay: 0, options: [], animations: {
      UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: 0.6) {
        imageView.transform = CGAffineTransformMakeScale(1.05, 1.05)
      }

      UIView.addKeyframeWithRelativeStartTime(0.6, relativeDuration: 0.4) {
        imageView.transform = CGAffineTransformIdentity
      }

    }, completion: { finished in
      
    })
  }

  // MARK: - Reload

  func reload(images: [Image], added: Bool = false) {
    // Animate empty view
    if added {
      if let emptyView = imageViews.filter({ $0.image == nil }).first {
        animate(imageView: emptyView)
      }
    }

    // Update images into views
    renderViews(images.map { $0.asset })

    // Update count label
    if let topVisibleView = imageViews.filter({ $0.alpha == 1.0 }).last where images.count > 1 {
      countLabel.center = topVisibleView.center
      countLabel.text = "\(images.count)"
      countLabel.hidden = false
      countLabel.sizeToFit()
    } else {
      countLabel.hidden = true
    }
  }
  
  // MARK: - Controls

  func makeIndicator() -> UIActivityIndicatorView {
    let indicator = UIActivityIndicatorView()
    indicator.alpha = 0

    return indicator
  }

  func makeImageViews() -> [UIImageView] {
    return Array(0..<Config.Camera.StackView.imageCount).map { _ in
      let imageView = UIImageView()

      imageView.contentMode = .ScaleAspectFill
      imageView.alpha = 0
      Utils.addRoundBorder(imageView)

      return imageView
    }
  }

  func makeCountLabel() -> UILabel {
    let label = UILabel()
    label.textColor = UIColor.whiteColor()
    label.font = UIFont.systemFontOfSize(20)
    label.textAlignment = .Center
    Utils.addShadow(label)
    label.hidden = true

    return label
  }

  func makeTapGR() -> UITapGestureRecognizer {
    let gr = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))

    return gr
  }
}
