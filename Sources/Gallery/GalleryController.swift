import UIKit
import AVFoundation

public protocol GalleryControllerDelegate: class {

  func galleryController(_ controller: GalleryController, didSelectImages images: [Image])
  func galleryController(_ controller: GalleryController, didSelectVideo video: Video)
  func galleryController(_ controller: GalleryController, requestLightbox images: [Image])
  func galleryControllerDidCancel(_ controller: GalleryController)
}

public class GalleryController: UIViewController, PermissionControllerDelegate {

  lazy var imagesController: ImagesController = self.makeImagesController()
  lazy var cameraController: CameraController = self.makeCameraController()
  lazy var videosController: VideosController = self.makeVideosController()

  lazy var pagesController: PagesController = self.makePagesController()
  lazy var permissionController: PermissionController = self.makePermissionController()
  public weak var delegate: GalleryControllerDelegate?
  public let cart = Cart()

  // MARK: - Init

  public required init() {
    super.init(nibName: nil, bundle: nil)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Life cycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    setup()

    if Permission.hasNeededPermissions {
      showMain()
    } else {
      showPermissionView()
    }
  }


  public override var prefersStatusBarHidden : Bool {
    return true
  }

  // MARK: - Logic

  func showMain() {
    g_addChildController(pagesController)
  }

  func showPermissionView() {
    g_addChildController(permissionController)
  }

  // MARK: - Child view controller

  func makeImagesController() -> ImagesController {
    let controller = ImagesController(cart: cart)
    controller.title = "Gallery.Images.Title".g_localize(fallback: "PHOTOS")

    return controller
  }

  func makeCameraController() -> CameraController {
    let controller = CameraController(cart: cart)
    controller.title = "Gallery.Camera.Title".g_localize(fallback: "CAMERA")

    return controller
  }

  func makeVideosController() -> VideosController {
    let controller = VideosController(cart: cart)
    controller.title = "Gallery.Videos.Title".g_localize(fallback: "VIDEOS")

    return controller
  }

  func makePagesController() -> PagesController {
    var controllers: [UIViewController] = []
    for tab in Config.tabsToShow {
      if tab == .imageTab {
        controllers.append(imagesController)
      } else if tab == .cameraTab {
        controllers.append(cameraController)
      } else if tab == .videoTab {
        controllers.append(videosController)
      }
    }
    assert(!controllers.isEmpty, "Must specify at least one controller.")

    let controller = PagesController(controllers: controllers)
    if let initialTab = Config.initialTab {
      assert(Config.tabsToShow.index(of: initialTab) != nil, "Must specify an initial tab that is in Config.tabsToShow.")
      controller.selectedIndex = Config.tabsToShow.index(of: initialTab)!
    } else {
      if let cameraIndex = Config.tabsToShow.index(of: .cameraTab) {
        controller.selectedIndex = cameraIndex
      } else {
        controller.selectedIndex = 0
      }
    }

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
        strongSelf.delegate?.galleryController(strongSelf, didSelectImages: strongSelf.cart.images)
      }
    }

    EventHub.shared.doneWithVideos = { [weak self] in
      if let strongSelf = self, let video = strongSelf.cart.video {
        strongSelf.delegate?.galleryController(strongSelf, didSelectVideo: video)
      }
    }

    EventHub.shared.stackViewTouched = { [weak self] in
      if let strongSelf = self {
        strongSelf.delegate?.galleryController(strongSelf, requestLightbox: strongSelf.cart.images)
      }
    }
  }

  // MARK: - PermissionControllerDelegate

  func permissionControllerDidFinish(_ controller: PermissionController) {
    showMain()
    permissionController.g_removeFromParentController()
  }
}
