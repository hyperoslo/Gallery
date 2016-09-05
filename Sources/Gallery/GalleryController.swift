import UIKit
import Cartography
import AVFoundation

public protocol GalleryControllerDelegate: class {

  func galleryController(controller: GalleryController, didSelectImages images: [UIImage])
  func galleryController(controller: GalleryController, didSelectVideo video: Video)
  func galleryController(controller: GalleryController, requestLightbox images: [UIImage])
  func galleryControllerDidCancel(controller: GalleryController)
}

public class GalleryController: UIViewController, PermissionControllerDelegate, PagesControllerDelegate {

  lazy var imagesController: ImagesController = self.makeImagesController()
  lazy var cameraController: CameraController = self.makeCameraController()
  lazy var videosController: VideosController = self.makeVideosController()

  enum Page: Int {
    case Images, Camera, Videos
  }

  lazy var pagesController: PagesController = self.makePagesController()
  lazy var permissionController: PermissionController = self.makePermissionController()
  public weak var delegate: GalleryControllerDelegate?

  // MARK: - Life cycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    setup()

    if Permission.hasPermissions {
      showMain()
    } else {
      showPermissionView()
    }
  }

  deinit {
    Cart.shared.reset()
  }

  public override func prefersStatusBarHidden() -> Bool {
    return true
  }

  // MARK: - Logic

  public func reload(images: [UIImage]) {
    Cart.shared.reload(images)
  }

  func showMain() {
    g_addChildController(pagesController)
  }

  func showPermissionView() {
    g_addChildController(permissionController)
  }

  // MARK: - Child view controller

  func makeImagesController() -> ImagesController {
    let controller = ImagesController()
    controller.title = "IMAGES"
    Cart.shared.add(delegate: controller)

    return controller
  }

  func makeCameraController() -> CameraController {
    let controller = CameraController()
    controller.title = "CAMERA"
    Cart.shared.add(delegate: controller)

    return controller
  }

  func makeVideosController() -> VideosController {
    let controller = VideosController()
    controller.title = "VIDEOS"

    return controller
  }

  func makePagesController() -> PagesController {
    let controller = PagesController(controllers: [imagesController, cameraController, videosController])
    controller.delegate = self

    return controller
  }

  func makePermissionController() -> PermissionController {
    let controller = PermissionController()
    controller.delegate = self

    return controller
  }

  // MARK: - Setup

  func setup() {
    EventHub.shared.close = { [weak self] in
      if let strongSelf = self {
        strongSelf.delegate?.galleryControllerDidCancel(strongSelf)
      }
    }

    EventHub.shared.doneWithImages = { [weak self] in
      if let strongSelf = self {
        strongSelf.delegate?.galleryController(strongSelf, didSelectImages: Cart.shared.UIImages())
      }
    }

    EventHub.shared.doneWithVideos = { [weak self] in
      if let strongSelf = self, video = Cart.shared.video {
        strongSelf.delegate?.galleryController(strongSelf, didSelectVideo: video)
      }
    }

    EventHub.shared.stackViewTouched = { [weak self] in
      if let strongSelf = self {
        strongSelf.delegate?.galleryController(strongSelf, requestLightbox: Cart.shared.UIImages())
      }
    }
  }

  // MARK: - PermissionControllerDelegate

  func permissionControllerDidFinish(controller: PermissionController) {
    showMain()
    permissionController.g_removeFromParentController()
  }

  // MARK: PagesControllerDelegate

  func pagesController(controller: PagesController, didSelect index: Int) {
    guard let page = Page(rawValue: index) else { return }

    switch page {
    case .Images:
      imagesController.viewWillAppear(false)
    case .Camera:
      break
    case .Videos:
      break
    }
  }
}
