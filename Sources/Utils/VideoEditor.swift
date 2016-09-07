import Foundation
import AVFoundation
import Photos

public class VideoEditor {

  // MARK: - Initialization

  public init() {

  }

  // MARK: - Edit
  
  public func edit(video: Video, completion: (Video?) -> Void) {
    video.fetchAVAsset { avAsset in
      guard let avAsset = avAsset else {
        completion(nil)
        return
      }

      self.crop(avAsset) { localIdentifier in
        if let localIdentifier = localIdentifier,
          phAsset = Fetcher.fetchAsset(localIdentifier) {
          completion(Video(asset: phAsset))
        } else {
          completion(nil)
        }
      }
    }
  }

  func crop(avAsset: AVAsset, completion: String? -> Void) {
    guard let outputURL = Info.outputURL() else {
      completion(nil)
      return
    }

    let export = AVAssetExportSession(asset: avAsset, presetName: Info.presetName(avAsset))
    export?.timeRange = Info.timeRange(avAsset)
    export?.outputURL = outputURL
    export?.outputFileType = Info.file().type
    export?.videoComposition = Info.composition(avAsset)

    var localIdentifier: String?
    export?.exportAsynchronouslyWithCompletionHandler {
      PHPhotoLibrary.sharedPhotoLibrary().performChanges({
        let request = PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(outputURL)
        localIdentifier = request?.placeholderForCreatedAsset?.localIdentifier
      }, completionHandler: { succeeded, info in
        print(export?.status)
        print(export?.error)
        if let localIdentifier = localIdentifier
          where succeeded && export?.status == AVAssetExportSessionStatus.Completed {
          completion(localIdentifier)
        } else {
          completion(nil)
        }
      })
    }
  }
}

// MARK: - Info

private struct Info {
  
  static func composition(avAsset: AVAsset) -> AVVideoComposition {
    let layer = AVMutableVideoCompositionLayerInstruction()
    let transform = CGAffineTransformMakeScale(0.5, 0.5)
    layer.setTransform(transform, atTime: kCMTimeZero)

    let instruction = AVMutableVideoCompositionInstruction()
    instruction.layerInstructions = [layer]

    let composition = AVMutableVideoComposition(propertiesOfAsset: avAsset)
    composition.instructions = [instruction]
    composition.frameDuration = CMTime(seconds: 1, preferredTimescale: CMTimeScale(avAsset.g_frameRate))

    return composition
  }

  static func cropSize(isPortrait: Bool) -> CGSize {
    if isPortrait {
      return CGSize(width: Config.VideoEditor.portraitWidth,
                    height: Config.VideoEditor.portraitWidth * Config.VideoEditor.ratio)
    } else {
      return CGSize(width: Config.VideoEditor.landscapeWidth,
                    height: Config.VideoEditor.landscapeWidth / Config.VideoEditor.ratio)
    }
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
    return AVAssetExportPresetLowQuality
  }

  static func timeRange(avAsset: AVAsset) -> CMTimeRange {
    var end = kCMTimePositiveInfinity

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

