import UIKit

class VideosController: UIViewController {

  lazy var gridController: GridController = self.makeGridController()

  // MARK: - Life cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    setup()
  }

  // MARK: - Setup

  func setup() {
    addChildViewController(gridController)
  }

  // MARK: - Controls

  func makeGridController() -> GridController {
    let controller = GridController()

    return controller
  }
}
