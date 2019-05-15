import UIKit
import Photos

class ImagesController: UIViewController {
    
    weak var galleryController: GalleryController?
    
    let columnCount: CGFloat = 3
    let spacing: CGFloat = 8
    
    var insets : UIEdgeInsets{
      return UIEdgeInsets(top: spacing, left: spacing, bottom: 36, right: spacing)
    }

  lazy var dropdownController: DropdownController = self.makeDropdownController()
  lazy var gridView: GridView = self.makeGridView()
  lazy var stackView: StackView = self.makeStackView()

  var items: [ArdhiMedia] = []
  let library = ImagesLibrary()
  let videoLibrary = VideosLibrary()
  var selectedAlbum: MediaAlbum?
  let once = Once()
  let cart: Cart
    
    var containerviewHeightConstraint: NSLayoutConstraint?
    
    var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var arrowButton: ArrowButton = {
        let btn = ArrowButton()
        btn.backgroundColor = UIColor.clear
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

  // MARK: - Init

  public required init(cart: Cart) {
    self.cart = cart
    super.init(nibName: nil, bundle: nil)
    cart.delegates.add(self)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
    
    enum ControllerMode {
        case image
        case video
    }
    var controllerMode: ControllerMode = .image
    
  // MARK: - Life cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    setup()
    setupDropDownController()
    view.backgroundColor = .black
    
    gridView.didTapButtonLeft = { _ in
        EventHub.shared.close?()
    }
    
    gridView.didTapButtonRight = { [unowned self] _ in
        guard self.controllerMode == .image else {
            EventHub.shared.doneWithVideos?()
            return
        }
        EventHub.shared.doneWithImages?()
    }
  }

  // MARK: - Setup
  func setup() {
    view.backgroundColor = UIColor.white
    view.addSubview(gridView)

    gridView.bottomView.addSubview(stackView)

    gridView.g_pinEdges()
    stackView.g_pin(on: .centerY, constant: -4)
    stackView.g_pin(on: .left, constant: 38)
    stackView.g_pin(size: CGSize(width: 56, height: 56))

    gridView.closeButton.addTarget(self, action: #selector(closeButtonTouched(_:)), for: .touchUpInside)
    gridView.doneButton.addTarget(self, action: #selector(doneButtonTouched(_:)), for: .touchUpInside)
    stackView.addTarget(self, action: #selector(stackViewTouched(_:)), for: .touchUpInside)

    gridView.collectionView.dataSource = self
    gridView.collectionView.delegate = self
    gridView.collectionView.register(ImageCell.self, forCellWithReuseIdentifier: String(describing: ImageCell.self))
    gridView.collectionView.register(VideoCell.self, forCellWithReuseIdentifier: String(describing: VideoCell.self))
  }
    
    @objc
    func arrowBtnTapped() {
       toggleContainerView()
    }
    
    var isExpanded: Bool = false
    
    func toggleContainerView() {
        isExpanded = !isExpanded
        arrowButton.toggle(isExpanded)
        gridView.isUserInteractionEnabled = !isExpanded
        containerviewHeightConstraint?.constant = containerviewHeightConstraint?.constant == 36 ? 378 : 36
        UIView.animate(withDuration: 0.25, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.view.layoutIfNeeded()
        }, completion: { finished in
            //            self.animating = false
        })
    }
    
    func setupDropDownController() {
        
        gridView.collectionView.contentInset = insets
        
        view.addSubview(containerView)
        containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        containerviewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: 36)
        containerviewHeightConstraint?.isActive = true
        
        // Button Top of view controller to be presented
        containerView.addSubview(arrowButton)
        arrowButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        arrowButton.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        arrowButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        arrowButton.addTarget(self, action: #selector(arrowBtnTapped), for: .touchUpInside)
        
        addChild(dropdownController)
        dropdownController.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(dropdownController.view)
        dropdownController.didMove(toParent: self)
        
        dropdownController.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        dropdownController.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        dropdownController.view.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 36).isActive = true
        dropdownController.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }

  // MARK: - Action

  @objc func closeButtonTouched(_ button: UIButton) {
    EventHub.shared.close?()
  }

  @objc func doneButtonTouched(_ button: UIButton) {
    EventHub.shared.doneWithImages?()
  }

  @objc func arrowButtonTouched(_ button: ArrowButton) {
    dropdownController.toggle()
    button.toggle(dropdownController.expanding)
  }

  @objc func stackViewTouched(_ stackView: StackView) {
    EventHub.shared.stackViewTouched?()
  }

  // MARK: - Logic

  func show(album: MediaAlbum) {
    arrowButton.updateText(album.title ?? "")
    switch album.mode {
    case .image(let images):
        items = images
    case .video(let videos):
        items = videos
    }
    gridView.collectionView.reloadData()
    gridView.collectionView.g_scrollToTop()
    gridView.emptyView.isHidden = !items.isEmpty
  }

  func refreshSelectedAlbum() {
    if let selectedAlbum = selectedAlbum {
      selectedAlbum.reload()
      show(album: selectedAlbum)
    }
  }

  // MARK: - View

  func refreshView() {
    let hasImages = !cart.images.isEmpty
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
    if Permission.Photos.status != .authorized {
        Permission.Photos.request { [weak self] in
            guard Permission.Photos.status == .authorized else {
                Alert.shared.show(from: self, mode: .library)
                return
            }
            self?.reload()
        }
    }

    once.run {
      reload()
    }
  }
    
    func reload() {
        library.reload { [weak self] in
            guard let welf = self else { return }
            welf.reloadLibraries()
        }
    }
    
    func reloadLibraries() {
        gridView.loadingIndicator.stopAnimating()
        var albums = [MediaAlbum]()
        albums = library.albums
        if !videoLibrary.items.isEmpty {
            albums.insert(VideoAlbum(videos: videoLibrary.items), at: 1)
        }
        dropdownController.albums = albums
        
        dropdownController.tableView.reloadData()
        
        if let album = library.albums.first {
            selectedAlbum = album
            show(album: album)
        }
    }
}

extension ImagesController: DropdownControllerDelegate {

  func dropdownController(_ controller: DropdownController, didSelect album: MediaAlbum) {
    cart.images = []
    cart.video = nil
    selectedAlbum = album
    show(album: album)
    toggleContainerView()
    updateTopView()
  }
    
    func updateTopView() {
        
    }
}

extension ImagesController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

  // MARK: - UICollectionViewDataSource

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return items.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    if let item = items[indexPath.item] as? Image {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ImageCell.self), for: indexPath)
            as! ImageCell
        cell.configure(item)
        configureFrameView(cell, indexPath: indexPath)
        return cell

    } else if let item = items[indexPath.item] as? Video {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: VideoCell.self), for: indexPath)
            as! VideoCell
        cell.configure(item)
        configureFrameViewVideo(cell, indexPath: indexPath)
        return cell
    }
    return UICollectionViewCell()
  }

  // MARK: - UICollectionViewDelegateFlowLayout

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

    let totalSpacing = (spacing * (columnCount - 1)) + insets.left + insets.right
    
    let size = (collectionView.bounds.size.width - totalSpacing) / columnCount
    return CGSize(width: size, height: size)
  }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    if let item = items[indexPath.item] as? Image  {
        cart.images = [item]
        EventHub.shared.doneWithImages?()
    } else if let item = items[indexPath.item] as? Video {
        cart.video = item
        EventHub.shared.doneWithVideos?()
    }
  }
    
    func configVideos(with item: Video) {
        if let selectedItem = cart.video, selectedItem == item {
            cart.video = nil
        } else {
            cart.video = item
        }
        configureFrameViewsforVideo()
    }
    
    func configureFrameViewsforVideo() {
        for case let cell as VideoCell in gridView.collectionView.visibleCells {
            if let indexPath = gridView.collectionView.indexPath(for: cell) {
                configureFrameViewVideo(cell, indexPath: indexPath)
            }
        }
        updateTopView()
    }
    
    func configureFrameViewVideo(_ cell: VideoCell, indexPath: IndexPath) {
        guard let item = items[(indexPath as NSIndexPath).item] as? Video else { return }
        
        if let selectedItem = cart.video , selectedItem == item {
            cell.frameView.g_quickFade()
        } else {
            cell.frameView.alpha = 0
        }
    }
    

  func configureFrameViews() {
    for case let cell as ImageCell in gridView.collectionView.visibleCells {
      if let indexPath = gridView.collectionView.indexPath(for: cell) {
        configureFrameView(cell, indexPath: indexPath)
      }
    }
    updateTopView()
  }

  func configureFrameView(_ cell: ImageCell, indexPath: IndexPath) {
    guard let item = items[(indexPath as NSIndexPath).item] as? Image else { return }

    if let _ = cart.images.index(of: item) {
      cell.frameView.g_quickFade()
    } else {
      cell.frameView.alpha = 0
    }
  }
}
