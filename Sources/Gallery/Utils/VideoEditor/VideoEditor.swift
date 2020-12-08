import Foundation
import AVFoundation
import Photos

public class VideoEditor: VideoEditing {

  // MARK: - Initialization

  public init() {

  }

  // MARK: - Edit

  public func edit(video: Video, completion: @escaping (_ video: Video?, _ tempPath: URL?) -> Void) {
    process(video: video, completion: completion)
  }

  public func crop(avAsset: AVAsset, completion: @escaping (URL?) -> Void) {
    guard let outputURL = EditInfo.outputURL else {
      completion(nil)
      return
    }

    let export = AVAssetExportSession(asset: avAsset, presetName: EditInfo.presetName(avAsset))
    export?.timeRange = EditInfo.timeRange(avAsset)
    export?.outputURL = outputURL
    export?.outputFileType = EditInfo.file.type
    export?.videoComposition = EditInfo.composition(avAsset)
    export?.shouldOptimizeForNetworkUse = true

    export?.exportAsynchronously {
        if export?.status == AVAssetExportSession.Status.completed {
        completion(outputURL)
      } else {
        completion(nil)
      }
    }
  }
}

