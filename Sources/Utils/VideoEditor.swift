import Foundation
import AVFoundation
import Photos

public class VideoEditor {

  // MARK: - Initialization

  public init() {

  }

  // MARK: - Edit
  
  public func edit(video: Video, completion: (video: Video?, tempPath: NSURL?) -> Void) {
    video.fetchAVAsset { avAsset in
      guard let avAsset = avAsset else {
        completion(video: nil, tempPath: nil)
        return
      }

      self.crop(avAsset) { (outputURL: NSURL?) in
        guard let outputURL = outputURL else {
          completion(video: nil, tempPath: nil)
          return
        }

        self.handle(outputURL, completion: completion)
      }
    }
  }

  func handle(outputURL: NSURL, completion: (video: Video?, tempPath: NSURL?) -> Void) {
    guard Config.VideoEditor.savesEditedVideoToLibrary else {
      completion(video: nil, tempPath: outputURL)
      return
    }

    var localIdentifier: String?
    PHPhotoLibrary.sharedPhotoLibrary().performChanges({
      let request = PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(outputURL)
      localIdentifier = request?.placeholderForCreatedAsset?.localIdentifier
    }, completionHandler: { succeeded, info in
      if let localIdentifier = localIdentifier, asset = Fetcher.fetchAsset(localIdentifier) {
        completion(video: Video(asset: asset), tempPath: outputURL)
      } else {
        completion(video: nil, tempPath: outputURL)
      }
    })
  }

  func crop(avAsset: AVAsset, completion: (NSURL?) -> Void) {
    guard let outputURL = Info.outputURL() else {
      completion(nil)
      return
    }

    let export = AVAssetExportSession(asset: avAsset, presetName: Info.presetName(avAsset))
    export?.timeRange = Info.timeRange(avAsset)
    export?.outputURL = outputURL
    export?.outputFileType = Info.file().type
    export?.videoComposition = Info.composition(avAsset)
    export?.shouldOptimizeForNetworkUse = true

    var localIdentifier: String?
    export?.exportAsynchronouslyWithCompletionHandler {
      if export?.status == AVAssetExportSessionStatus.Completed {
        completion(outputURL)
      } else {
        completion(nil)
      }
    }
  }
}

// MARK: - Info

private struct Info {

  static func composition(avAsset: AVAsset) -> AVVideoComposition? {
    guard let track = avAsset.tracksWithMediaType(AVMediaTypeVideo).first else { return nil }

    let cropInfo = Info.cropInfo(avAsset)

    let layer = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
    let transform = CGAffineTransformMakeScale(cropInfo.scale, cropInfo.scale)
    layer.setTransform(transform, atTime: kCMTimeZero)

    let instruction = AVMutableVideoCompositionInstruction()
    instruction.layerInstructions = [layer]
    instruction.timeRange = Info.timeRange(avAsset)

    let composition = AVMutableVideoComposition(propertiesOfAsset: avAsset)
    composition.instructions = [instruction]
    composition.renderSize = cropInfo.size

    return composition
  }

  static func cropInfo(avAsset: AVAsset) -> (size: CGSize, scale: CGFloat) {
    var desiredSize = avAsset.g_isPortrait ? Config.VideoEditor.portraitSize : Config.VideoEditor.landscapeSize
    let avAssetSize = avAsset.g_size

    let ratio = min(desiredSize.width / avAssetSize.width, desiredSize.height / avAssetSize.height)
    let size = CGSize(width: avAssetSize.width*ratio, height: avAssetSize.height*ratio)

    return (size: size, scale: ratio)
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

