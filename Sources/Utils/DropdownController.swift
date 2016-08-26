import UIKit
import Cartography

class DropdownController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  var items: [String] = []
  lazy var tableView: UITableView = self.makeTableView()

  // MARK: - Initialization

  // MARK: - Life cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    setup()
  }

  // MARK: - Setup

  func setup() {
    view.addSubview(tableView)

    constrain(tableView) {
      tableView in

      tableView.edges == tableView.superview!.edges
    }
  }

  // MARK: - UITableViewDataSource

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    fatalError()
  }

  // MARK: - UITableViewDelegate

  // MARK: - Controls

  func makeTableView() -> UITableView {
    let tableView = UITableView()
    tableView.dataSource = self
    tableView.delegate = self

    return tableView
  }
}
