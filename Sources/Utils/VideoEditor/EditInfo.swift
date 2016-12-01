import UIKit
import AVFoundation

struct EditInfo {

  // MARK: - Basic

  static func composition(_ avAsset: AVAsset) -> AVVideoComposition? {
    guard let track = avAsset.tracks(withMediaType: AVMediaTypeVideo).first else { return nil }

    let cropInfo = EditInfo.cropInfo(avAsset)

    let layer = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
    layer.setTransform(EditInfo.transform(avAsset, scale: cropInfo.scale), at: kCMTimeZero)

    let instruction = AVMutableVideoCompositionInstruction()
    instruction.layerInstructions = [layer]
    instruction.timeRange = timeRange(avAsset)

    let composition = AVMutableVideoComposition(propertiesOf: avAsset)
    composition.instructions = [instruction]
    composition.renderSize = cropInfo.size

    return composition
  }

  static func cropInfo(_ avAsset: AVAsset) -> (size: CGSize, scale: CGFloat) {
    let desiredSize = avAsset.g_isPortrait ? Config.VideoEditor.portraitSize : Config.VideoEditor.landscapeSize
    let avAssetSize = avAsset.g_correctSize

    let scale = min(desiredSize.width / avAssetSize.width, desiredSize.height / avAssetSize.height)
    let size = CGSize(width: avAssetSize.width*scale, height: avAssetSize.height*scale)

    return (size: size, scale: scale)
  }

  static func transform(_ avAsset: AVAsset, scale: CGFloat) -> CGAffineTransform {
    let offset: CGPoint
    let angle: Double

    switch avAsset.g_orientation {
    case .landscapeLeft:
      offset = CGPoint(x: avAsset.g_correctSize.width, y: avAsset.g_correctSize.height)
      angle = M_PI
    case .landscapeRight:
      offset = CGPoint.zero
      angle = 0
    case .portraitUpsideDown:
      offset = CGPoint(x: 0, y: avAsset.g_correctSize.height)
      angle = -M_PI_2
    default:
      offset = CGPoint(x: avAsset.g_correctSize.width, y: 0)
      angle = M_PI_2
    }

    let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
    let translationTransform = scaleTransform.translatedBy(x: offset.x, y: offset.y)
    let rotationTransform = translationTransform.rotated(by: CGFloat(angle))

    return rotationTransform
  }

  static func presetName(_ avAsset: AVAsset) -> String {
    let availablePresets = AVAssetExportSession.exportPresets(compatibleWith: avAsset)

    if availablePresets.contains(preferredPresetName) {
      return preferredPresetName
    } else {
      return availablePresets.first ?? AVAssetExportPresetHighestQuality
    }
  }

  static var preferredPresetName: String {
    return Config.VideoEditor.quality
  }

  static func timeRange(_ avAsset: AVAsset) -> CMTimeRange {
    var end = avAsset.duration

    if Config.VideoEditor.maximumDuration < avAsset.duration.seconds {
      end = CMTime(seconds: Config.VideoEditor.maximumDuration, preferredTimescale: 1000)
    }

    return CMTimeRange(start: kCMTimeZero, duration: end)
  }

  static var file: (type: String, pathExtension: String) {
    return (type: AVFileTypeMPEG4, pathExtension: "mp4")
  }

  static var outputURL: URL? {
    return URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
      .appendingPathComponent(UUID().uuidString)
      .appendingPathExtension(file.pathExtension)
  }

  // MARK: - Advanced

  static var audioSettings: [String: AnyObject] {
    return [
      AVFormatIDKey: NSNumber(value: Int(kAudioFormatMPEG4AAC) as Int),
      AVNumberOfChannelsKey: NSNumber(value: 2 as Int),
      AVSampleRateKey: NSNumber(value: 44100 as Int),
      AVEncoderBitRateKey: NSNumber(value: 128000 as Int)
    ]
  }

  static var videoSettings: [String: AnyObject] {
    let compression: [String: Any] = [
      AVVideoAverageBitRateKey: NSNumber(value: 6000000),
      AVVideoProfileLevelKey: AVVideoProfileLevelH264High40
    ]

    return [
      AVVideoCodecKey: AVVideoCodecH264 as AnyObject,
      AVVideoWidthKey: NSNumber(value: 1920 as Int),
      AVVideoHeightKey: NSNumber(value: 1080 as Int),
      AVVideoCompressionPropertiesKey: compression as AnyObject
    ]
  }
}

