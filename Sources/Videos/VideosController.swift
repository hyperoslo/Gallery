import UIKit
import Cartography
import Photos
import AVKit

class VideosController: UIViewController {

  lazy var gridView: GridView = self.makeGridView()
  lazy var videoBox: VideoBox = self.makeVideoBox()
  lazy var infoLabel: UILabel = self.makeInfoLabel()

  var items: [Video] = []
  let library = VideosLibrary()
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

      videoBox.width == 48
      videoBox.height == 48
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
    EventHub.shared.close?()
  }

  func doneButtonTouched(button: UIButton) {
    EventHub.shared.doneWithVideos?()
  }

  // MARK: - View

  func refreshView() {
    if let selectedItem = Cart.shared.video {
      videoBox.imageView.g_loadImage(selectedItem.asset)
    } else {
      videoBox.imageView.image = nil
    }

    let hasVideo = (Cart.shared.video != nil)
    gridView.bottomView.g_fade(visible: hasVideo)
    gridView.collectionView.g_updateBottomInset(hasVideo ? gridView.bottomView.frame.size.height : 0)
  }

  // MARK: - Controls

  func makeGridView() -> GridView {
    let view = GridView()
    view.bottomView.alpha = 0
    
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
    label.font = Config.Font.Text.regular.fontWithSize(12)
    label.text = String(format: "Gallery.Videos.MaxiumDuration".g_localize(fallback: "FIRST %d SECONDS"),
                        (Int(Config.VideoEditor.maximumDuration)))

    return label
  }
}

extension VideosController: PageAware {

  func pageDidShow() {
    once.run {
      library.reload {
        self.items = self.library.items
        self.gridView.collectionView.reloadData()
      }
    }
  }
}

extension VideosController: VideoBoxDelegate {

  func videoBoxDidTap(videoBox: VideoBox) {
    Cart.shared.video?.fetchPlayerItem { item in
      guard let item = item else { return }

      Dispatch.main {
        let controller = AVPlayerViewController()
        let player = AVPlayer(playerItem: item)
        controller.player = player

        self.presentViewController(controller, animated: true) {
          player.play()
        }
      }
    }
  }
}

extension VideosController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

  // MARK: - UICollectionViewDataSource

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    gridView.emptyView.hidden = !items.isEmpty
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

    if let selectedItem = Cart.shared.video where selectedItem == item {
      Cart.shared.video = nil
    } else {
      Cart.shared.video = item
    }

    refreshView()
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

    if let selectedItem = Cart.shared.video where selectedItem == item {
      cell.frameView.g_quickFade()
    } else {
      cell.frameView.alpha = 0
    }
  }
}
