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

    for (index, imageView) in imageViews.enumerated() {
      let origin = CGPoint(x: CGFloat(index) * step,
                           y: CGFloat(imageViews.count - index) * step)
      imageView.frame = CGRect(origin: origin, size: imageViewSize)
    }
  }

  // MARK: - Action

  @objc func viewTapped(_ gr: UITapGestureRecognizer) {
    sendActions(for: .touchUpInside)
  }

  // MARK: - Logic

  func startLoading() {
    if let topVisibleView = imageViews.filter({ $0.alpha == 1.0 }).last {
      indicator.center = topVisibleView.center
    } else if let first = imageViews.first {
      indicator.center = first.center
    }

    indicator.startAnimating()
    UIView.animate(withDuration: 0.3, animations: {
      self.indicator.alpha = 1.0
    }) 
  }

  func stopLoading() {
    indicator.stopAnimating()
    indicator.alpha = 0
  }

  func renderViews(_ assets: [PHAsset]) {
    let photos = Array(assets.suffix(Config.Camera.StackView.imageCount))

    for (index, view) in imageViews.enumerated() {
      if index < photos.count {
        view.g_loadImage(photos[index])
        view.alpha = 1
      } else {
        view.image = nil
        view.alpha = 0
      }
    }
  }

  fileprivate func animate(imageView: UIImageView) {
    imageView.transform = CGAffineTransform(scaleX: 0, y: 0)

    UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: [], animations: {
      UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.6) {
        imageView.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
      }

      UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4) {
        imageView.transform = CGAffineTransform.identity
      }

    }, completion: { finished in
      
    })
  }

  // MARK: - Reload

  func reload(_ images: [Image], added: Bool = false) {
    // Animate empty view
    if added {
      if let emptyView = imageViews.filter({ $0.image == nil }).first {
        animate(imageView: emptyView)
      }
    }

    // Update images into views
    renderViews(images.map { $0.asset })

    // Update count label
    if let topVisibleView = imageViews.filter({ $0.alpha == 1.0 }).last , images.count > 1 {
      countLabel.text = "\(images.count)"
      countLabel.sizeToFit()
      countLabel.center = topVisibleView.center
      countLabel.g_quickFade()
    } else {
      countLabel.alpha = 0
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

      imageView.contentMode = .scaleAspectFill
      imageView.alpha = 0
      imageView.g_addRoundBorder()

      return imageView
    }
  }

  func makeCountLabel() -> UILabel {
    let label = UILabel()
    label.textColor = UIColor.white
    label.font = Config.Font.Main.regular.withSize(20)
    label.textAlignment = .center
    label.g_addShadow()
    label.alpha = 0

    return label
  }

  func makeTapGR() -> UITapGestureRecognizer {
    let gr = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))

    return gr
  }
}
