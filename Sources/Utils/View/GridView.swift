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
  lazy var emptyView: UIView = self.makeEmptyView()

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
    backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5)

    [collectionView, bottomView, topView, emptyView].forEach {
      addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }

    [closeButton, arrowButton].forEach {
      topView.addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }

    [bottomBlurView, doneButton].forEach {
      bottomView.addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }

    constrain(topView, collectionView, bottomView, emptyView) {
      topView, collectionView, bottomView, emptyView in

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

      emptyView.edges == collectionView.edges
    }

    constrain(bottomBlurView) {
      bottomBlurView in

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
    button.setTitleColor(UIColor.lightGrayColor(), forState: .Disabled)
    button.titleLabel?.font = Config.Font.Text.regular.fontWithSize(16)
    button.setTitle("Gallery.Done".g_localize(fallback: "Done"), forState: .Normal)
    
    return button
  }

  func makeCollectionView() -> UICollectionView {
    let layout = UICollectionViewFlowLayout()
    layout.minimumInteritemSpacing = 2
    layout.minimumLineSpacing = 2

    let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
    view.backgroundColor = UIColor.whiteColor()

    return view
  }

  func makeEmptyView() -> EmptyView {
    let view = EmptyView()
    view.hidden = true

    return view
  }
}
