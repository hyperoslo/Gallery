import Foundation
import AVFoundation
import Photos

public class VideoEditor {

  // MARK: - Initialization

  public init() {

  }

  // MARK: - Edit
  
  public func edit(video: Video, completion: (Video) -> Void) {
    video.fetchAVAsset { avAsset in
      self.crop(avAsset!) { _ in

      }
    }
  }

  func crop(avAsset: AVAsset, completion: AVAsset? -> Void) {
    guard let outputURL = Info.outputURL() else {
      completion(nil)
      return
    }

    let export = AVAssetExportSession(asset: avAsset, presetName: Info.presetName(avAsset))
    export?.timeRange = Info.timeRange()
    export?.outputURL = outputURL
    export?.outputFileType = AVFileTypeMPEG4

    let composition = AVVideoComposition(propertiesOfAsset: avAsset)
    export?.videoComposition = composition

    export?.exportAsynchronouslyWithCompletionHandler {
      PHPhotoLibrary.sharedPhotoLibrary().performChanges({
        let request = PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(outputURL)
      }, completionHandler: { success, info in
        print(success)
        print(info)
      })
    }
  }

  // MARK: - Info 

  struct Info {
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
      return AVAssetExportPresetMediumQuality
    }

    static func timeRange() -> CMTimeRange {
      let start = CMTime(seconds: 0, preferredTimescale: 1000)
      let end = CMTime(seconds: Config.VideoEditor.maximumDuration, preferredTimescale: 1000)

      return CMTimeRange(start: start, duration: end)
    }

    static func outputURL() -> NSURL? {
      return NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(NSUUID().UUIDString)
    }
  }
}
