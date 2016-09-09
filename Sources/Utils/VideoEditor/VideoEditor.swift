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
    guard let outputURL = EditInfo.outputURL() else {
      completion(nil)
      return
    }

    let export = AVAssetExportSession(asset: avAsset, presetName: EditInfo.presetName(avAsset))
    export?.timeRange = EditInfo.timeRange(avAsset)
    export?.outputURL = outputURL
    export?.outputFileType = EditInfo.file().type
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

