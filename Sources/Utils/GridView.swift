import UIKit
import Photos

class GridView: UICollectionView, UICollectionViewDataSource, UICollectionViewDelegate {

  var items: [PHAsset] = []

  // MARK: - Initialization

  override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
    super.init(frame: frame, collectionViewLayout: layout)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - UICollectionViewDataSource

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return items.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    fatalError()
  }

  // MARK: - UICollectionViewDelegate
}
