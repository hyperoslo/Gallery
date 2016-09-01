import UIKit
import Photos
import Cartography

class GridView: UIView {

  // MARK: - Initialization

  lazy var topView: UIView = self.makeTopView()
  lazy var bottomView: UIView = self.makeBottomView()
  lazy var bottomBlurView: UIVisualEffectView = self.makeBottomBlurView()
  lazy var arrowButton: ArrowButton = self.makeArrowButton()
  lazy var collectionView: UICollectionView = self.makeCollectionView()
  lazy var closeButton: UIButton = self.makeCloseButton()
  lazy var doneButton: UIButton = self.makeDoneButton()

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
    [collectionView, bottomView, topView].forEach {
      self.addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }

    [closeButton, arrowButton].forEach {
      self.topView.addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }

    [bottomBlurView, doneButton].forEach {
      self.bottomView.addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }

    constrain(topView, collectionView, bottomView, bottomBlurView) {
      topView, collectionView, bottomView, bottomBlurView in

      topView.left == topView.superview!.left
      topView.top == topView.superview!.top
      topView.right == topView.superview!.right
      topView.height == 40

      collectionView.top == topView.bottom + 1
      collectionView.left == collectionView.superview!.left
      collectionView.right == collectionView.superview!.right
      collectionView.bottom == collectionView.superview!.bottom

      bottomView.left == bottomView.superview!.left
      bottomView.right == bottomView.superview!.right
      bottomView.bottom == bottomView.superview!.bottom
      bottomView.height == 80

      bottomBlurView.edges == bottomBlurView.superview!.edges
    }

    constrain(closeButton, arrowButton) {
      closeButton, arrowButton in

      closeButton.top == closeButton.superview!.top
      closeButton.left == closeButton.superview!.left
      closeButton.width == 40
      closeButton.height == 40

      arrowButton.center == arrowButton.superview!.center
      arrowButton.height == 40
    }

    constrain(doneButton) {
      doneButton in

      doneButton.centerY == doneButton.superview!.centerY
      doneButton.right == doneButton.superview!.right - 38
    }
  }

  // MARK: - Controls

  func makeTopView() -> UIView {
    let view = UIView()
    view.backgroundColor = UIColor.whiteColor()

    return view
  }

  func makeBottomView() -> UIView {
    let view = UIView()

    return view
  }

  func makeBottomBlurView() -> UIVisualEffectView {
    let view = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))

    return view
  }

  func makeArrowButton() -> ArrowButton {
    let button = ArrowButton()
    button.label.text = "ALL PHOTOS"
    button.layoutSubviews()

    return button
  }

  func makeGridView() -> GridView {
    let view = GridView()

    return view
  }

  func makeCloseButton() -> UIButton {
    let button = UIButton(type: .Custom)
    button.setImage(Bundle.image("gallery_close")?.imageWithRenderingMode(.AlwaysTemplate), forState: .Normal)
    button.tintColor = Config.Grid.CloseButton.tintColor

    return button
  }

  func makeDoneButton() -> UIButton {
    let button = UIButton(type: .System)
    button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    button.titleLabel?.font = UIFont.systemFontOfSize(16)
    button.setTitle("Done", forState: .Normal)
    button.enabled = false
    
    return button
  }

  func makeCollectionView() -> UICollectionView {
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 2
    layout.minimumLineSpacing = 2

    let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
    view.backgroundColor = UIColor.whiteColor()
    view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 80, right: 0)
    view.scrollIndicatorInsets = view.contentInset

    return view
  }
}
