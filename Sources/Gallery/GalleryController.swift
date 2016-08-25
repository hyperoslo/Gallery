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

    setup()
  }

  public override func prefersStatusBarHidden() -> Bool {
    return true
  }

  // MARK: - Child view controller

  func makeImagesController() -> ImagesController {
    let controller = ImagesController()
    controller.view.backgroundColor = UIColor.redColor()
    controller.title = "Images"

    return controller
  }

  func makeCameraController() -> CameraController {
    let controller = CameraController()
    controller.title = "Camera"

    return controller
  }

  func makeVideosController() -> VideosController {
    let controller = VideosController()
    controller.view.backgroundColor = UIColor.blueColor()
    controller.title = "Videos"

    return controller
  }

  func makePagesController() -> PagesController {
    let controller = PagesController(controllers: [imagesController, cameraController, videosController])

    return controller
  }

  // MARK: - Setup

  func setup() {
    addChildViewController(pagesController)
    view.addSubview(pagesController.view)
    pagesController.didMoveToParentViewController(self)

    pagesController.view.translatesAutoresizingMaskIntoConstraints = false

    constrain(pagesController.view) { view in
      view.edges == view.superview!.edges
    }
  }
}
