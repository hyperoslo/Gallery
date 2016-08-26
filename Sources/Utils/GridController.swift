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

    gridView.closeButton.addTarget(self, action: #selector(closeButtonTouched(_:)), forControlEvents: .TouchUpInside)
    gridView.doneButton.addTarget(self, action: #selector(doneButtonTouched(_:)), forControlEvents: .TouchUpInside)
    gridView.arrowButton.addTarget(self, action: #selector(arrowButtonTouched(_:)), forControlEvents: .TouchUpInside)
  }

  // MARK: - Action

  func closeButtonTouched(button: UIButton) {
    dismissViewControllerAnimated(true, completion: nil)
  }

  func doneButtonTouched(button: UIButton) {

  }

  func arrowButtonTouched(button: ArrowButton) {
    button.toggle()
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
