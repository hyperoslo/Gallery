import UIKit
import AVFoundation

extension AVAsset {

  private var g_naturalSize: CGSize {
    return tracksWithMediaType(AVMediaTypeVideo).first?.naturalSize ?? .zero
  }

  var g_correctSize: CGSize {
    return g_isPortrait ? CGSize(width: g_naturalSize.height, height: g_naturalSize.width) : g_naturalSize
  }

  var g_isPortrait: Bool {
    let portraits: [UIInterfaceOrientation] = [.Portrait, .PortraitUpsideDown]
    return portraits.contains(g_orientation)
  }

  var g_fileSize: Double {
    guard let avURLAsset = self as? AVURLAsset else { return 0 }

    var result: AnyObject?
    try? avURLAsset.URL.getResourceValue(&result, forKey: NSURLFileSizeKey)

    if let result = result as? NSNumber {
      return result.doubleValue
    } else {
      return 0
    }
  }

  var g_frameRate: Float {
    return tracksWithMediaType(AVMediaTypeVideo).first?.nominalFrameRate ?? 30
  }

  // Same as UIImageOrientation
  var g_orientation: UIInterfaceOrientation {
    guard let transform = tracksWithMediaType(AVMediaTypeVideo).first?.preferredTransform else {
      return .Portrait
    }

    switch (transform.tx, transform.ty) {
    case (0, 0):
      return .LandscapeRight
    case (g_naturalSize.width, g_naturalSize.height):
      return .LandscapeLeft
    case (0, g_naturalSize.width):
      return .PortraitUpsideDown
    default:
      return .Portrait
    }
  }

  // MARK: - Description

  var g_videoDescription: CMFormatDescription? {
    if let object = tracksWithMediaType(AVMediaTypeVideo).first?.formatDescriptions.first {
      return object as! CMFormatDescription
    }

    return nil
  }

  var g_audioDescription: CMFormatDescription? {
    if let object = tracksWithMediaType(AVMediaTypeAudio).first?.formatDescriptions.first {
      return object as! CMFormatDescription
    }

    return nil
  }
}
