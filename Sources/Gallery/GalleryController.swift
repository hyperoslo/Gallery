import UIKit
import Cartography

public class GalleryController: UIViewController {

  lazy var imagesController: ImagesController = self.makeImagesController()
  lazy var cameraController: CameraController = self.makeCameraController()
  lazy var videosController: VideosController = self.makeVideosController()

  lazy var pagesController: PagesController = self.makePagesController()

  // MARK: - Life cycle

  public override func viewDidLoad() {
    super.viewDidLoad()

    Cart.shared.reset()
    Permission.request()
    setup()
  }

  public override func prefersStatusBarHidden() -> Bool {
    return true
  }

  // MARK: - Child view controller

  func makeImagesController() -> ImagesController {
    let controller = ImagesController()
    controller.title = "Images"
    Cart.shared.add(delegate: controller)

    return controller
  }

  func makeCameraController() -> CameraController {
    let controller = CameraController()
    controller.title = "Camera"
    Cart.shared.add(delegate: controller)

    return controller
  }

  func makeVideosController() -> VideosController {
    let controller = VideosController()
    controller.title = "Videos"

    return controller
  }

  func makePagesController() -> PagesController {
    let controller = PagesController(controllers: [imagesController, cameraController, videosController])

    return controller
  }

  // MARK: - Setup

  func setup() {
    addChildController(pagesController)
  }
}
