import UIKit
import AVFoundation

public protocol GalleryControllerDelegate: class {

  func galleryController(_ controller: GalleryController, didSelectImages images: [Image])
  func galleryController(_ controller: GalleryController, didSelectVideo video: Video)
  func galleryController(_ controller: GalleryController, requestLightbox images: [Image], doneAction: @escaping ()->())
  func galleryControllerDidCancel(_ controller: GalleryController)
}

public class GalleryController: UIViewController, PermissionControllerDelegate {

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

    if let pagesController = makePagesController() {
      g_addChildController(pagesController)
      eventuallyPresentIntroductionController()
    } else {
      let permissionController = makePermissionController()
      g_addChildController(permissionController)
    }
  }
    
  public override var prefersStatusBarHidden : Bool {
    return true
  }
  
  // MARK: - Introduction controller
    
  func eventuallyPresentIntroductionController() {
    guard let introductionController = Config.Introduction.viewController else { return }
    introductionController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
    introductionController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
    DispatchQueue.main.async {
      self.present(introductionController, animated: true, completion: nil)
    }
  }

  // MARK: - Child view controller

  func makeImagesController() -> ImagesController {
    let controller = ImagesController(cart: cart)
    controller.title = Config.Images.title

    return controller
  }

  func makeCameraController() -> CameraController {
    let controller = CameraController(cart: cart)
    controller.title = Config.Camera.title

    return controller
  }

  func makeVideosController() -> VideosController {
    let controller = VideosController(cart: cart)
    controller.title = Config.Videos.title

    return controller
  }

  func makePagesController() -> PagesController? {
      guard Permission.Camera.status == .authorized && Permission.Photos.status == .authorized else {
      return nil
    }

    let useCamera = Permission.Camera.needsPermission && Permission.Camera.status == .authorized

    let tabsToShow = Config.tabsToShow.flatMap { $0 != .cameraTab ? $0 : (useCamera ? $0 : nil) }

    let controllers: [UIViewController] = tabsToShow.flatMap { tab in
      if tab == .imageTab {
        return makeImagesController()
      } else if tab == .cameraTab {
        return makeCameraController()
      } else if tab == .videoTab {
        return makeVideosController()
      } else {
        return nil
      }
    }

    guard !controllers.isEmpty else {
      return nil
    }

    let controller = PagesController(controllers: controllers)
    controller.selectedIndex = tabsToShow.index(of: Config.initialTab ?? .cameraTab) ?? 0

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
    
    let doneAction = { [weak self] in
      if let strongSelf = self {
        strongSelf.delegate?.galleryController(strongSelf, didSelectImages: strongSelf.cart.images)
      }
    }

    EventHub.shared.stackViewTouched = { [weak self] in
      if let strongSelf = self {
        strongSelf.delegate?.galleryController(strongSelf, requestLightbox: strongSelf.cart.images, doneAction: doneAction)
      }
    }
  }

  // MARK: - PermissionControllerDelegate

  func permissionControllerDidFinish(_ controller: PermissionController) {
    if let pagesController = makePagesController() {
      g_addChildController(pagesController)
      controller.g_removeFromParentController()
      eventuallyPresentIntroductionController()
    }
  }
}
