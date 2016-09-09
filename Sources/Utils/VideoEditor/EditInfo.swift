import UIKit
import AVFoundation

struct EditInfo {

  static func composition(avAsset: AVAsset) -> AVVideoComposition? {
    guard let track = avAsset.tracksWithMediaType(AVMediaTypeVideo).first else { return nil }

    let cropInfo = EditInfo.cropInfo(avAsset)

    let layer = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
    layer.setTransform(EditInfo.transform(avAsset, scale: cropInfo.scale), atTime: kCMTimeZero)

    let instruction = AVMutableVideoCompositionInstruction()
    instruction.layerInstructions = [layer]
    instruction.timeRange = timeRange(avAsset)

    let composition = AVMutableVideoComposition(propertiesOfAsset: avAsset)
    composition.instructions = [instruction]
    composition.renderSize = cropInfo.size

    return composition
  }

  static func cropInfo(avAsset: AVAsset) -> (size: CGSize, scale: CGFloat) {
    var desiredSize = avAsset.g_isPortrait ? Config.VideoEditor.portraitSize : Config.VideoEditor.landscapeSize
    let avAssetSize = avAsset.g_correctSize

    let scale = min(desiredSize.width / avAssetSize.width, desiredSize.height / avAssetSize.height)
    let size = CGSize(width: avAssetSize.width*scale, height: avAssetSize.height*scale)

    return (size: size, scale: scale)
  }

  static func transform(avAsset: AVAsset, scale: CGFloat) -> CGAffineTransform {
    let offset: CGPoint
    let angle: Double

    switch avAsset.g_orientation {
    case .LandscapeLeft:
      offset = CGPoint(x: avAsset.g_correctSize.width, y: avAsset.g_correctSize.height)
      angle = M_PI
    case .LandscapeRight:
      offset = CGPoint.zero
      angle = 0
    case .PortraitUpsideDown:
      offset = CGPoint(x: 0, y: avAsset.g_correctSize.height)
      angle = -M_PI_2
    default:
      offset = CGPoint(x: avAsset.g_correctSize.width, y: 0)
      angle = M_PI_2
    }

    let scaleTransform = CGAffineTransformMakeScale(scale, scale)
    let translationTransform = CGAffineTransformTranslate(scaleTransform, offset.x, offset.y)
    let rotationTransform = CGAffineTransformRotate(translationTransform, CGFloat(angle))

    return rotationTransform
  }

  static func presetName(avAsset: AVAsset) -> String {
    let availablePresets = AVAssetExportSession.exportPresetsCompatibleWithAsset(avAsset)

    if availablePresets.contains(preferredPresetName()) {
      return preferredPresetName()
    } else {
      return availablePresets.first ?? AVAssetExportPresetMediumQuality
    }
  }

  static func preferredPresetName() -> String {
    return AVAssetExportPresetMediumQuality
  }

  static func timeRange(avAsset: AVAsset) -> CMTimeRange {
    var end = avAsset.duration

    if Config.VideoEditor.maximumDuration < avAsset.duration.seconds {
      end = CMTime(seconds: Config.VideoEditor.maximumDuration, preferredTimescale: 1000)
    }

    return CMTimeRange(start: kCMTimeZero, duration: end)
  }

  static func file() -> (type: String, pathExtension: String) {
    return (type: AVFileTypeMPEG4, pathExtension: "mp4")
  }

  static func outputURL() -> NSURL? {
    return NSURL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
      .URLByAppendingPathComponent(NSUUID().UUIDString)
      .URLByAppendingPathExtension(file().pathExtension)
  }
}

