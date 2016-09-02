import Foundation
import Photos

struct Permission {

  static func request() {
    PHPhotoLibrary.requestAuthorization { status in

    }
  }
}
