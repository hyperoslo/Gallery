import UIKit
import Cartography

class AlbumCell: UITableViewCell {

  lazy var albumImageView: UIImageView = self.makeAlbumImageView()
  lazy var albumTitleLabel: UILabel = self.makeAlbumTitleLabel()
  lazy var itemCountLabel: UILabel = self.makeItemCountLabel()

  // MARK: - Initialization

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Setup

  func setup() {
    [albumImageView, albumTitleLabel, itemCountLabel].forEach {
      addSubview($0)
      $0.translatesAutoresizingMaskIntoConstraints = false
    }

    constrain(albumImageView, albumTitleLabel, itemCountLabel) {
      albumImageView, albumTitleLabel, itemCountLabel in

      albumImageView.left == albumImageView.superview!.left + 5
      albumImageView.top == albumImageView.superview!.top + 5
      albumImageView.bottom == albumImageView.superview!.bottom - 5
      albumImageView.width == albumImageView.height

      albumTitleLabel.left == albumImageView.right + 10
      albumTitleLabel.top == albumTitleLabel.superview!.top + 10

      itemCountLabel.left == albumImageView.right + 10
      itemCountLabel.top == albumTitleLabel.bottom + 10
    }
  }

  // MARK: - Controls

  func makeAlbumImageView() -> UIImageView {
    let imageView = UIImageView()

    return imageView
  }

  func makeAlbumTitleLabel() -> UILabel {
    let label = UILabel()
    label.numberOfLines = 1

    return label
  }

  func makeItemCountLabel() -> UILabel {
    let label = UILabel()
    label.numberOfLines = 1

    return label
  }
}
