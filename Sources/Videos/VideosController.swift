import UIKit
import Cartography
import Photos

class VideosController: UIViewController, UICollectionViewDataSource,
  UICollectionViewDelegateFlowLayout, VideoBoxDelegate {

  lazy var gridView: GridView = self.makeGridView()
  lazy var videoBox: VideoBox = self.makeVideoBox()
  lazy var infoLabel: UILabel = self.makeInfoLabel()

  var items: [Video] = []
  var selectedItem: Video? = nil {
    didSet {
      if let selectedItem = selectedItem {
        videoBox.imageView.loadImage(selectedItem.asset)
      } else {
        videoBox.imageView.image = nil
      }
    }
  }

  let library = VideosLibrary()

  // MARK: - Life cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    setup()

    library.reload()
    items = library.items
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    gridView.collectionView.reloadData()
  }

  // MARK: - Setup

  func setup() {
    view.addSubview(gridView)
    gridView.translatesAutoresizingMaskIntoConstraints = false

    [videoBox, infoLabel].forEach {
      self.gridView.bottomView.addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }

    constrain(gridView) {
      gridView in

      gridView.edges == gridView.superview!.edges
    }

    constrain(videoBox, infoLabel) {
      videoBox, infoLabel in

      videoBox.width == 44
      videoBox.height == 44
      videoBox.centerY == videoBox.superview!.centerY
      videoBox.left == videoBox.superview!.left + 16

      infoLabel.centerY == infoLabel.superview!.centerY
      infoLabel.left == videoBox.right + 11
      infoLabel.right == infoLabel.superview!.right - 50
    }

    gridView.closeButton.addTarget(self, action: #selector(closeButtonTouched(_:)), forControlEvents: .TouchUpInside)
    gridView.doneButton.addTarget(self, action: #selector(doneButtonTouched(_:)), forControlEvents: .TouchUpInside)

    gridView.collectionView.dataSource = self
    gridView.collectionView.delegate = self
    gridView.collectionView.registerClass(VideoCell.self, forCellWithReuseIdentifier: String(VideoCell.self))

    gridView.arrowButton.updateText("ALL VIDEOS")
    gridView.arrowButton.arrow.hidden = true
  }

  // MARK: - Action

  func closeButtonTouched(button: UIButton) {
    dismissViewControllerAnimated(true, completion: nil)
  }

  func doneButtonTouched(button: UIButton) {

  }

  // MARK: - UICollectionViewDataSource

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return items.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(String(VideoCell.self), forIndexPath: indexPath)
      as! VideoCell
    let item = items[indexPath.item]

    cell.configure(item)
    cell.frameView.label.hidden = true
    configureFrameView(cell, indexPath: indexPath)

    return cell
  }

  // MARK: - UICollectionViewDelegateFlowLayout

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

    let size = (collectionView.bounds.size.width - (Config.Grid.Dimension.columnCount - 1) * Config.Grid.Dimension.cellSpacing)
      / Config.Grid.Dimension.columnCount
    return CGSize(width: size, height: size)
  }

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let item = items[indexPath.item]

    if let selectedItem = selectedItem where selectedItem == item {
      self.selectedItem = nil
    } else {
      selectedItem = item
    }

    configureFrameViews()
  }

  func configureFrameViews() {
    for case let cell as VideoCell in gridView.collectionView.visibleCells() {
      if let indexPath = gridView.collectionView.indexPathForCell(cell) {
        configureFrameView(cell, indexPath: indexPath)
      }
    }
  }

  func configureFrameView(cell: VideoCell, indexPath: NSIndexPath) {
    let item = items[indexPath.item]

    if let selectedItem = selectedItem where selectedItem == item {
      cell.frameView.hidden = false
    } else {
      cell.frameView.hidden = true
    }
  }

  // MARK: - VideoBoxDelegate

  func videoBoxDidTap(videoBox: VideoBox) {

  }

  // MARK: - Controls

  func makeGridView() -> GridView {
    let view = GridView()
    
    return view
  }

  func makeVideoBox() -> VideoBox {
    let videoBox = VideoBox()
    videoBox.delegate = self

    return videoBox
  }

  func makeInfoLabel() -> UILabel {
    let label = UILabel()
    label.textColor = UIColor.whiteColor()
    label.font = UIFont.systemFontOfSize(12)

    label.text = "FIRST 15 SECONDS"

    return label
  }
}
