import UIKit
import Cartography

public protocol GalleryControllerDelegate: class {

  func galleryController(controller: GalleryController, didSelect images: [UIImage])
  func galleryController(controller: GalleryController, didSelect video: Video)
  func galleryController(controller: GalleryController, requestLightbox images: [UIImage])
  func galleryControllerDidCancel(controller: GalleryController)
}

public class GalleryController: UIViewController, PermissionControllerDelegate {

  lazy var imagesController: ImagesController = self.makeImagesController()
  lazy var cameraController: CameraController = self.makeCameraController()
  lazy var videosController: VideosController = self.makeVideosController()

  lazy var pagesController: PagesController = self.makePagesController()
  lazy var permissionController: PermissionController = self.makePermissionController()
  public weak var delegate: GalleryControllerDelegate?

  // MARK: - Life cycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    Cart.shared.reset()
    setup()

    if Permission.hasPermissions {
      showMain()
    } else {
      showPermissionView()
    }
  }

  public override func prefersStatusBarHidden() -> Bool {
    return true
  }

  // MARK: - Logic

  public func reload(images: [UIImage]) {
    Cart.shared.reload(images)
  }

  func showMain() {
    addChildController(pagesController)
  }

  func showPermissionView() {
    addChildController(permissionController)
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
        strongSelf.delegate?.galleryController(strongSelf, didSelect: Cart.shared.UIImages())
      }
    }

    EventHub.shared.doneWithVideos = { [weak self] in
      if let strongSelf = self, video = Cart.shared.video {
        strongSelf.delegate?.galleryController(strongSelf, didSelect: video)
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
//    permissionController.removeFromParentController()
  }
}
