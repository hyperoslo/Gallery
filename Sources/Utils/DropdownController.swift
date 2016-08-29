import UIKit
import Cartography
import Photos

class DropdownController: UIViewController, UITableViewDataSource, UITableViewDelegate {

  var albums: [Album] = []
  lazy var tableView: UITableView = self.makeTableView()

  var animating: Bool = false
  var expanding: Bool = false

  var topConstraint: NSLayoutConstraint?

  // MARK: - Initialization

  // MARK: - Life cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    setup()
  }

  // MARK: - Setup

  func setup() {
    view.addSubview(tableView)
    tableView.translatesAutoresizingMaskIntoConstraints = false
    tableView.rowHeight = 80

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

    UIView.animateWithDuration(0.5, delay: 0,
                               usingSpringWithDamping: 0.7,
                               initialSpringVelocity: 0.5,
                               options: [],
                               animations:
    {
      self.view.superview?.layoutIfNeeded()
    }, completion: { finished in
      self.animating = false
    })
  }

  // MARK: - UITableViewDataSource

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return albums.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(String(AlbumCell.self), forIndexPath: indexPath)
                as! AlbumCell

    let album = albums[indexPath.row]

    cell.albumTitleLabel.text = album.collection.localizedTitle
    cell.itemCountLabel.text = "\(album.items.count)"
    album.fetchThumbnail {
      cell.albumImageView.image = $0
    }

    return cell
  }

  // MARK: - UITableViewDelegate

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }

  // MARK: - Controls

  func makeTableView() -> UITableView {
    let tableView = UITableView()
    tableView.tableFooterView = UIView()
    tableView.separatorStyle = .None

    tableView.dataSource = self
    tableView.delegate = self

    return tableView
  }
}
