import UIKit
import Photos

struct Fetcher {
  static func fetchAsset(_ localIdentifer: String) -> PHAsset? {
    return PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifer], options: nil).firstObject
  }
}
