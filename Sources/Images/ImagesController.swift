import UIKit

class ImagesController: UIViewController {

  lazy var gridController: GridController = self.makeGridController()

  // MARK: - Life cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    setup()
  }

  // MARK: - Setup

  func setup() {
    addChildController(gridController)
  }

  // MARK: - Controls

  func makeGridController() -> GridController {
    let controller = GridController()

    return controller
  }
}
