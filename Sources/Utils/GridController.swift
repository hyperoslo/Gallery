import UIKit
import Cartography
import Photos

class GridController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

  lazy var dropdownController: DropdownController = self.makeDropdownController()
  lazy var gridView: GridView = self.makeGridView()

  var items: [PHAsset] = []
  var selectedItems: [PHAsset] = []

  // MARK: - Life cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    setup()

    gridView.collectionView.registerClass(ImageCell.self, forCellWithReuseIdentifier: "Cell")

    LibraryAssets.fetch { assets in
      self.items = assets
      self.gridView.collectionView.reloadData()
    }
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
    gridView.arrowButton.addTarget(self, action: #selector(arrowButtonTouched(_:)), forControlEvents: .TouchUpInside)

    gridView.collectionView.dataSource = self
    gridView.collectionView.delegate = self
  }

  // MARK: - Action

  func closeButtonTouched(button: UIButton) {
    dismissViewControllerAnimated(true, completion: nil)
  }

  func doneButtonTouched(button: UIButton) {

  }

  func arrowButtonTouched(button: ArrowButton) {
    button.toggle()
  }

  // MARK: - UICollectionViewDataSource

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return items.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ImageCell

    LibraryAssets.resolveAsset(items[indexPath.item]) { image in
      cell.imageView.image = image
    }

    return cell
  }

  // MARK: - UICollectionViewDelegateFlowLayout

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

    let size = (collectionView.bounds.size.width - 6) / 4
    return CGSize(width: size, height: size)
  }

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
  }

  // MARK: - Controls

  func makeDropdownController() -> DropdownController {
    let controller = DropdownController()

    return controller
  }

  func makeGridView() -> GridView {
    let view = GridView()

    return view
  }
}
