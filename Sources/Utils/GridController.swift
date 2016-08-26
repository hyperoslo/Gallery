import UIKit
import Cartography

class GridController: UIViewController {

  lazy var dropdownController: DropdownController = self.makeDropdownController()
  lazy var gridView: GridView = self.makeGridView()

  // MARK: - Life cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    setup()
  }

  // MARK: - Setup

  func setup() {
    view.addSubview(gridView)
    gridView.translatesAutoresizingMaskIntoConstraints = false

    constrain(gridView) {
      gridView in

      gridView.edges == gridView.superview!.edges
    }
  }

  // MARK: - Controls

  func makeDropdownController() -> DropdownController {
    let controller = DropdownController()

    return controller
  }

  func makeGridView() -> GridView {
    let view = GridView()

    return view
  }
}
