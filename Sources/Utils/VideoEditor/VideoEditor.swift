import Foundation
import AVFoundation
import Photos

public class VideoEditor: VideoEditing {

  // MARK: - Initialization

  public init() {

  }

  // MARK: - Crop
  
  public func crop(avAsset: AVAsset, completion: (NSURL?) -> Void) {
    guard let outputURL = EditInfo.outputURL() else {
      completion(nil)
      return
    }

    let export = AVAssetExportSession(asset: avAsset, presetName: EditInfo.presetName(avAsset))
    export?.timeRange = EditInfo.timeRange(avAsset)
    export?.outputURL = outputURL
    export?.outputFileType = EditInfo.file.type
    export?.videoComposition = EditInfo.composition(avAsset)
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

