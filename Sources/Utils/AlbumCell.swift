import UIKit
import Cartography

class AlbumCell: UITableViewCell {

  lazy var albumImageView: UIImageView = self.makeAlbumImageView()
  lazy var albumTitleLabel: UILabel = self.makeAlbumTitleLabel()
  lazy var itemCountLabel: UILabel = self.makeItemCountLabel()
  lazy var separator: UIView = self.makeSeparator()

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
    [albumImageView, albumTitleLabel, itemCountLabel, separator].forEach {
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
      albumTitleLabel.top == albumTitleLabel.superview!.top + 20
      albumTitleLabel.right == albumTitleLabel.superview!.right - 10

      itemCountLabel.left == albumImageView.right + 10
      itemCountLabel.top == albumTitleLabel.bottom + 10
    }

    constrain(separator) {
      separator in

      separator.left == separator.superview!.left
      separator.right == separator.superview!.right
      separator.bottom == separator.superview!.bottom
      separator.height == 1
    }
  }

  // MARK: - Controls

  func makeAlbumImageView() -> UIImageView {
    let imageView = UIImageView()
    imageView.image = BundleAsset.image("gallery_placeholder")

    Utils.addShadow(imageView)

    return imageView
  }

  func makeAlbumTitleLabel() -> UILabel {
    let label = UILabel()
    label.numberOfLines = 1
    label.font = UIFont.systemFontOfSize(15)

    return label
  }

  func makeItemCountLabel() -> UILabel {
    let label = UILabel()
    label.numberOfLines = 1
    label.font = UIFont.systemFontOfSize(12)

    return label
  }

  func makeSeparator() -> UIView {
    let view = UIView()
    view.backgroundColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5)

    return view
  }
}
