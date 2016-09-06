import AVFoundation

extension AVAsset {

  var g_size: CGSize {
    return tracksWithMediaType(AVMediaTypeVideo).first?.naturalSize ?? .zero
  }

  var g_isPortrait: Bool {
    return g_size.height > g_size.width
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
}
