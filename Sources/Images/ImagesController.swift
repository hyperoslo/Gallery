import UIKit
import Cartography
import Photos

class ImagesController: UIViewController {

  lazy var dropdownController: DropdownController = self.makeDropdownController()
  lazy var gridView: GridView = self.makeGridView()
  lazy var stackView: StackView = self.makeStackView()

  var items: [Image] = []
  let library = ImagesLibrary()
  var selectedAlbum: Album?
  let once = Once()

  // MARK: - Life cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    setup()
  }

  // MARK: - Setup

  func setup() {
    view.backgroundColor = UIColor.whiteColor()

    view.addSubview(gridView)
    gridView.translatesAutoresizingMaskIntoConstraints = false

    addChildViewController(dropdownController)
    gridView.insertSubview(dropdownController.view, belowSubview: gridView.topView)
    dropdownController.didMoveToParentViewController(self)

    gridView.bottomView.addSubview(stackView)
    stackView.translatesAutoresizingMaskIntoConstraints = false

    constrain(gridView) {
      gridView in

      gridView.edges == gridView.superview!.edges
    }

    constrain(dropdownController.view, gridView.topView) {
      dropdown, topView in

      dropdown.left == dropdown.superview!.left
      dropdown.right == dropdown.superview!.right
      dropdown.height == dropdown.superview!.height - 40
      self.dropdownController.topConstraint = (dropdown.top == topView.bottom + self.view.frame.size.height ~ 999 )
    }

    constrain(stackView, gridView.bottomView) {
      stackView, bottomView in

      stackView.centerY == stackView.superview!.centerY - 4
      stackView.left == stackView.superview!.left + 38
      stackView.width == 56
      stackView.height == 56
    }

    gridView.closeButton.addTarget(self, action: #selector(closeButtonTouched(_:)), forControlEvents: .TouchUpInside)
    gridView.doneButton.addTarget(self, action: #selector(doneButtonTouched(_:)), forControlEvents: .TouchUpInside)
    gridView.arrowButton.addTarget(self, action: #selector(arrowButtonTouched(_:)), forControlEvents: .TouchUpInside)
    stackView.addTarget(self, action: #selector(stackViewTouched(_:)), forControlEvents: .TouchUpInside)

    gridView.collectionView.dataSource = self
    gridView.collectionView.delegate = self
    gridView.collectionView.registerClass(ImageCell.self, forCellWithReuseIdentifier: String(ImageCell.self))
  }

  // MARK: - Action

  func closeButtonTouched(button: UIButton) {
    EventHub.shared.close?()
  }

  func doneButtonTouched(button: UIButton) {
    EventHub.shared.doneWithImages?()
  }

  func arrowButtonTouched(button: ArrowButton) {
    dropdownController.toggle()
    button.toggle(dropdownController.expanding)
  }

  func stackViewTouched(stackView: StackView) {
    EventHub.shared.stackViewTouched?()
  }

  // MARK: - Logic

  func show(album album: Album) {
    gridView.arrowButton.updateText(album.collection.localizedTitle ?? "Images")
    items = album.items
    gridView.collectionView.reloadData()
    gridView.collectionView.g_scrollToTop()
  }

  func refreshSelectedAlbum() {
    if let selectedAlbum = selectedAlbum {
      selectedAlbum.reload()
      show(album: selectedAlbum)
    }
  }

  // MARK: - View

  func refreshView() {
    let hasImages = !Cart.shared.images.isEmpty
    gridView.bottomView.g_fade(visible: hasImages)
    gridView.collectionView.g_updateBottomInset(hasImages ? gridView.bottomView.frame.size.height : 0)
  }

  // MARK: - Controls

  func makeDropdownController() -> DropdownController {
    let controller = DropdownController()
    controller.delegate = self
    
    return controller
  }
  
  func makeGridView() -> GridView {
    let view = GridView()
    view.bottomView.alpha = 0
    
    return view
  }

  func makeStackView() -> StackView {
    let view = StackView()

    return view
  }
}

extension ImagesController: PageAware {

  func pageDidShow() {
    once.run {
      library.reload {
        self.dropdownController.albums = self.library.albums
        self.dropdownController.tableView.reloadData()

        if let album = self.library.albums.first {
          self.selectedAlbum = album
          self.show(album: album)
        }
      }
    }
  }
}

extension ImagesController: CartDelegate {

  func cart(cart: Cart, didAdd image: Image, newlyTaken: Bool) {
    stackView.reload(cart.images, added: true)
    refreshView()

    if newlyTaken {
      refreshSelectedAlbum()
    }
  }

  func cart(cart: Cart, didRemove image: Image) {
    stackView.reload(cart.images)
    refreshView()
  }

  func cartDidReload(cart: Cart) {
    stackView.reload(cart.images)
    refreshView()
    refreshSelectedAlbum()
  }
}

extension ImagesController: DropdownControllerDelegate {

  func dropdownController(controller: DropdownController, didSelect album: Album) {
    selectedAlbum = album
    show(album: album)

    dropdownController.toggle()
    gridView.arrowButton.toggle(controller.expanding)
  }
}

extension ImagesController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

  // MARK: - UICollectionViewDataSource

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    gridView.emptyView.hidden = !items.isEmpty
    return items.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(String(ImageCell.self), forIndexPath: indexPath)
      as! ImageCell
    let item = items[indexPath.item]

    cell.configure(item)
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

    if Cart.shared.images.contains(item) {
      Cart.shared.remove(item)
    } else {
      Cart.shared.add(item)
    }

    configureFrameViews()
  }

  func configureFrameViews() {
    for case let cell as ImageCell in gridView.collectionView.visibleCells() {
      if let indexPath = gridView.collectionView.indexPathForCell(cell) {
        configureFrameView(cell, indexPath: indexPath)
      }
    }
  }

  func configureFrameView(cell: ImageCell, indexPath: NSIndexPath) {
    let item = items[indexPath.item]

    if let index = Cart.shared.images.indexOf(item) {
      cell.frameView.g_quickFade()
      cell.frameView.label.text = "\(index + 1)"
    } else {
      cell.frameView.alpha = 0
    }
  }
}
