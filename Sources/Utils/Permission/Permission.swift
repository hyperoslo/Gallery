import Foundation
import Photos
import AVFoundation

struct Permission {

  static var hasNeededPermissions: Bool {
    return (!Photos.needsPermission || Photos.hasPermission) && (!Camera.needsPermission || Camera.hasPermission)
  }

  struct Photos {
    static var needsPermission: Bool {
      return Config.tabsToShow.index(of: .imageTab) != nil || Config.tabsToShow.index(of: .videoTab) != nil
    }
    
    static var hasPermission: Bool {
      return PHPhotoLibrary.authorizationStatus() == .authorized
    }

    static func request(_ completion: @escaping () -> Void) {
      PHPhotoLibrary.requestAuthorization { status in
        completion()
      }
    }
  }

  struct Camera {
    static var needsPermission: Bool {
      return Config.tabsToShow.index(of: .cameraTab) != nil
    }

    static var hasPermission: Bool {
      return AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .authorized
    }

    static func request(_ completion: @escaping () -> Void) {
      AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo) { granted in
        completion()
      }
    }
  }
}
