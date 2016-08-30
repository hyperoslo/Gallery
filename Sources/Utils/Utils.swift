import UIKit
import AVFoundation
import Photos

struct Utils {

  static func rotationTransform() -> CGAffineTransform {
    switch UIDevice.currentDevice().orientation {
    case .LandscapeLeft:
      return CGAffineTransformMakeRotation(CGFloat(M_PI_2))
    case .LandscapeRight:
      return CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
    case .PortraitUpsideDown:
      return CGAffineTransformMakeRotation(CGFloat(M_PI))
    default:
      return CGAffineTransformIdentity
    }
  }

  static func videoOrientation() -> AVCaptureVideoOrientation {
    switch UIDevice.currentDevice().orientation {
    case .Portrait:
      return .Portrait
    case .LandscapeLeft:
      return .LandscapeRight
    case .LandscapeRight:
      return .LandscapeLeft
    case .PortraitUpsideDown:
      return .PortraitUpsideDown
    default:
      return .Portrait
    }
  }

  static func addShadow(view: UIView) {
    view.layer.shadowColor = UIColor.blackColor().CGColor
    view.layer.shadowOpacity = 0.5
    view.layer.shadowOffset = CGSize(width: 0, height: 1)
    view.layer.shadowRadius = 1
  }

  static func fetchOptions() -> PHFetchOptions {
    var options = PHFetchOptions()
    options.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: false)]

    return options
  }
}