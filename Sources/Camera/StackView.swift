import UIKit
import Photos

class StackView: UIControl {

  lazy var indicator: UIActivityIndicatorView = self.makeIndicator()
  lazy var imageViews: [UIImageView] = self.makeImageViews()
  lazy var tapGR: UITapGestureRecognizer = self.makeTapGR()

  struct Dimensions {
    static let imageSize: CGFloat = 58
  }
  
  let imageCount = 4

  // MARK: - Initialization

  override init(frame: CGRect) {
    super.init(frame: frame)

    setup()
    subscribe()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  // MARK: - Setup

  func setup() {
    addGestureRecognizer(tapGR)
    imageViews.forEach {
      addSubview($0)
    }

    addSubview(indicator)

    imageViews.first?.alpha = 1
  }

  // MARK: - Layout

  override func layoutSubviews() {
    super.layoutSubviews()

    let step: CGFloat = -3.0
    let scale: CGFloat = 0.8
    let viewSize = CGSize(width: frame.width * scale,
                          height: frame.height * scale)

    let offset = -step * CGFloat(imageViews.count)
    var origin = CGPoint(x: offset, y: offset)

    for view in imageViews {
      origin.x += step
      origin.y += step
      view.frame = CGRect(origin: origin, size: viewSize)
    }
  }

  // MARK: - Action

  func viewTapped(gr: UITapGestureRecognizer) {
    sendActionsForControlEvents(.TouchUpInside)
  }

  // MARK: - Logic

  func startLoader() {
    if let firstVisibleView = imageViews.filter({ $0.alpha == 1.0 }).last {
      indicator.frame.origin.x = firstVisibleView.center.x
      indicator.frame.origin.y = firstVisibleView.center.y
    }

    indicator.startAnimating()
    UIView.animateWithDuration(0.3) {
      self.indicator.alpha = 1.0
    }
  }

  func imageDidPush(notification: NSNotification) {
    let emptyView = imageViews.filter { $0.image == nil }.first

    if let emptyView = emptyView {
      animateImageView(emptyView)
    }

    if let sender = notification.object as? ImageStack {
      renderViews(sender.assets)
      indicator.stopAnimating()
    }
  }

  func imageStackDidChangeContent(notification: NSNotification) {
    if let sender = notification.object as? ImageStack {
      renderViews(sender.assets)
      indicator.stopAnimating()
    }
  }

  func renderViews(assets: [PHAsset]) {
    if let firstView = imageViews.first where assets.isEmpty {
      imageViews.forEach{
        $0.image = nil
        $0.alpha = 0
      }

      firstView.alpha = 1
      return
    }

    let photos = Array(assets.suffix(4))

    for (index, view) in imageViews.enumerate() {
      if index <= photos.count - 1 {
        Fetcher.resolveAsset(photos[index], size: CGSize(width: Dimensions.imageSize, height: Dimensions.imageSize)) { image in
          view.image = image
        }
        view.alpha = 1
      } else {
        view.image = nil
        view.alpha = 0
      }

      if index == photos.count {
        UIView.animateWithDuration(0.3) {
          self.indicator.frame.origin = CGPoint(x: view.center.x + 3, y: view.center.x + 3)
        }
      }
    }
  }

  private func animateImageView(imageView: UIImageView) {
    imageView.transform = CGAffineTransformMakeScale(0, 0)

    UIView.animateWithDuration(0.3, animations: {
      imageView.transform = CGAffineTransformMakeScale(1.05, 1.05)
    }) { _ in
      UIView.animateWithDuration(0.2, animations: { () -> Void in
        self.indicator.alpha = 0.0
        imageView.transform = CGAffineTransformIdentity
        }, completion: { _ in
          self.indicator.stopAnimating()
      })
    }
  }

  // MARK: - Notification

  func subscribe() {
    NSNotificationCenter.defaultCenter().addObserver(self,
                                                     selector: #selector(imageDidPush(_:)),
                                                     name: ImageStack.Notifications.imageDidPush,
                                                     object: nil)

    NSNotificationCenter.defaultCenter().addObserver(self,
                                                     selector: #selector(imageStackDidChangeContent(_:)),
                                                     name: ImageStack.Notifications.imageDidDrop,
                                                     object: nil)
    
    NSNotificationCenter.defaultCenter().addObserver(self,
                                                     selector: #selector(imageStackDidChangeContent(_:)),
                                                     name: ImageStack.Notifications.stackDidReload,
                                                     object: nil)
  }

  // MARK: - Controls

  func makeIndicator() -> UIActivityIndicatorView {
    let indicator = UIActivityIndicatorView()
    indicator.alpha = 0

    return indicator
  }

  func makeImageViews() -> [UIImageView] {
    return Array(0..<imageCount).map { _ in
      let imageView = UIImageView()

      imageView.layer.cornerRadius = 3
      imageView.layer.borderColor = UIColor.whiteColor().CGColor
      imageView.layer.borderWidth = 1
      imageView.contentMode = .ScaleAspectFill
      imageView.clipsToBounds = true
      imageView.alpha = 0

      return imageView
    }
  }

  func makeTapGR() -> UITapGestureRecognizer {
    let gr = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))

    return gr
  }
}
