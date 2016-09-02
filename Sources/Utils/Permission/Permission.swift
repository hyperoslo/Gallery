import Foundation
import Photos
import AVFoundation

struct Permission {

  static var hasPermissions: Bool {
    return Photos.hasPermission && Camera.hasPermission
  }

  struct Photos {
    static var hasPermission: Bool {
      return PHPhotoLibrary.authorizationStatus() == .Authorized
    }

    static func request(completion: () -> Void) {
      PHPhotoLibrary.requestAuthorization { status in
        completion()
      }
    }
  }

  struct Camera {
    static var hasPermission: Bool {
      return AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo) == .Authorized
    }

    static func request(completion: () -> Void) {
      AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { granted in
        completion()
      }
    }
  }
}
