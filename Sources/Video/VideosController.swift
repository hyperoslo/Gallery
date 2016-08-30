import UIKit
import Cartography
import Photos

class VideosController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

  lazy var gridView: GridView = self.makeGridView()

  var items: [PHAsset] = []
  var selectedItems: [PHAsset] = []
  let library: Library = Library(type: .Image)

  struct Dimension {
    static let columnCount: CGFloat = 4
    static let cellSpacing: CGFloat = 2
  }

  // MARK: - Life cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    setup()

    gridView.collectionView.registerClass(VideoCell.self, forCellWithReuseIdentifier: String(VideoCell.self))

    library.reload()
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    gridView.collectionView.reloadData()
  }

  // MARK: - Setup

  func setup() {
    view.addSubview(gridView)
    gridView.translatesAutoresizingMaskIntoConstraints = false

    constrain(gridView) {
      gridView in

      gridView.edges == gridView.superview!.edges
    }

    gridView.closeButton.addTarget(self, action: #selector(closeButtonTouched(_:)), forControlEvents: .TouchUpInside)
    gridView.doneButton.addTarget(self, action: #selector(doneButtonTouched(_:)), forControlEvents: .TouchUpInside)

    gridView.collectionView.dataSource = self
    gridView.collectionView.delegate = self
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
    configureFrameView(cell, indexPath: indexPath)

    return cell
  }

  // MARK: - UICollectionViewDelegateFlowLayout

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

    let size = (collectionView.bounds.size.width - (Dimension.columnCount - 1) * Dimension.cellSpacing)
      / Dimension.columnCount
    return CGSize(width: size, height: size)
  }

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let item = items[indexPath.item]

    if !selectedItems.contains(item) {
      selectedItems.append(item)
    }

    configureFrameViews()
  }

  func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
    let item = items[indexPath.item]

    if let index = selectedItems.indexOf(item) {
      selectedItems.removeAtIndex(index)
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

    if let index = selectedItems.indexOf(item) {
      cell.frameView.hidden = false
      cell.frameView.label.text = "\(index + 1)"
    } else {
      cell.frameView.hidden = true
    }
  }

  func makeGridView() -> GridView {
    let view = GridView()
    
    return view
  }
}
