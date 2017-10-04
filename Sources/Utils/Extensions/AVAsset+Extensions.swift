import UIKit
import AVFoundation

extension AVAsset {

  fileprivate var g_naturalSize: CGSize {
    return tracks(withMediaType: AVMediaType.video).first?.naturalSize ?? .zero
  }

  var g_correctSize: CGSize {
    return g_isPortrait ? CGSize(width: g_naturalSize.height, height: g_naturalSize.width) : g_naturalSize
  }

  var g_isPortrait: Bool {
    let portraits: [UIInterfaceOrientation] = [.portrait, .portraitUpsideDown]
    return portraits.contains(g_orientation)
  }

  var g_fileSize: Double {
    guard let avURLAsset = self as? AVURLAsset else { return 0 }

    var result: AnyObject?
    try? (avURLAsset.url as NSURL).getResourceValue(&result, forKey: URLResourceKey.fileSizeKey)

    if let result = result as? NSNumber {
      return result.doubleValue
    } else {
      return 0
    }
  }

  var g_frameRate: Float {
    return tracks(withMediaType: AVMediaType.video).first?.nominalFrameRate ?? 30
  }

  // Same as UIImageOrientation
  var g_orientation: UIInterfaceOrientation {
    guard let transform = tracks(withMediaType: AVMediaType.video).first?.preferredTransform else {
      return .portrait
    }

    switch (transform.tx, transform.ty) {
    case (0, 0):
      return .landscapeRight
    case (g_naturalSize.width, g_naturalSize.height):
      return .landscapeLeft
    case (0, g_naturalSize.width):
      return .portraitUpsideDown
    default:
      return .portrait
    }
  }

  // MARK: - Description

  var g_videoDescription: CMFormatDescription? {
    guard let object = tracks(withMediaType: AVMediaType.video).first?.formatDescriptions.first else {
      return nil
    }

    return (object as! CMFormatDescription)
  }

  var g_audioDescription: CMFormatDescription? {
    guard let object = tracks(withMediaType: AVMediaType.audio).first?.formatDescriptions.first else {
      return nil
    }

    return (object as! CMFormatDescription)
  }
}
