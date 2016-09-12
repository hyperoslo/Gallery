import UIKit
import Cartography
import Photos

protocol DropdownControllerDelegate: class {
  func dropdownController(controller: DropdownController, didSelect album: Album)
}

class DropdownController: UIViewController {

  lazy var tableView: UITableView = self.makeTableView()
  lazy var blurView: UIVisualEffectView = self.makeBlurView()

  var animating: Bool = false
  var expanding: Bool = false
  var selectedIndex: Int = 0

  var albums: [Album] = [] {
    didSet {
      selectedIndex = 0
    }
  }

  var topConstraint: NSLayoutConstraint?
  weak var delegate: DropdownControllerDelegate?

  // MARK: - Initialization

  // MARK: - Life cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    setup()
  }

  // MARK: - Setup

  func setup() {
    view.backgroundColor = UIColor.clearColor()
    tableView.backgroundColor = UIColor.clearColor()
    tableView.backgroundView = blurView

    [tableView].forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview($0)
    }

    tableView.registerClass(AlbumCell.self, forCellReuseIdentifier: String(AlbumCell.self))

    constrain(tableView) {
      tableView in

      tableView.edges == tableView.superview!.edges
    }
  }

  // MARK: - Logic

  func toggle() {
    guard !animating else { return }

    animating = true
    expanding = !expanding

    self.topConstraint?.constant = expanding ? 1 : view.bounds.size.height

    UIView.animateWithDuration(0.25, delay: 0, options: .CurveEaseInOut, animations: {
      self.view.superview?.layoutIfNeeded()
    }, completion: { finished in
      self.animating = false
    })
  }

  // MARK: - Controls

  func makeTableView() -> UITableView {
    let tableView = UITableView()
    tableView.tableFooterView = UIView()
    tableView.separatorStyle = .None
    tableView.rowHeight = 84

    tableView.dataSource = self
    tableView.delegate = self

    return tableView
  }

  func makeBlurView() -> UIVisualEffectView {
    let view = UIVisualEffectView(effect: UIBlurEffect(style: .Light))

    return view
  }
}

extension DropdownController: UITableViewDataSource, UITableViewDelegate {

  // MARK: - UITableViewDataSource

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return albums.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(String(AlbumCell.self), forIndexPath: indexPath)
      as! AlbumCell

    let album = albums[indexPath.row]
    cell.configure(album)
    cell.backgroundColor = UIColor.clearColor()

    return cell
  }

  // MARK: - UITableViewDelegate

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)

    let album = albums[indexPath.row]
    delegate?.dropdownController(self, didSelect: album)

    selectedIndex = indexPath.row
    tableView.reloadData()
  }
}

