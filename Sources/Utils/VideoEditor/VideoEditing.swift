import UIKit
import AVFoundation
import Photos

public protocol VideoEditing: class {

  func crop(avAsset: AVAsset, completion: @escaping (URL?) -> Void)
  func edit(video: Video, completion: @escaping (_ video: Video?, _ tempPath: URL?) -> Void)
}

extension VideoEditing {

  public func process(video: Video, completion: @escaping (_ video: Video?, _ tempPath: URL?) -> Void) {
    video.fetchAVAsset { avAsset in
      guard let avAsset = avAsset else {
        completion(nil, nil)
        return
      }

      self.crop(avAsset: avAsset) { (outputURL: URL?) in
        guard let outputURL = outputURL else {
          completion(nil, nil)
          return
        }

        self.handle(outputURL: outputURL, completion: completion)
      }
    }
  }

  func handle(outputURL: URL, completion: @escaping (_ video: Video?, _ tempPath: URL?) -> Void) {
    guard Config.VideoEditor.savesEditedVideoToLibrary else {
      completion(nil, outputURL)
      return
    }

    var localIdentifier: String?
    PHPhotoLibrary.shared().performChanges({
      let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
      localIdentifier = request?.placeholderForCreatedAsset?.localIdentifier
      }, completionHandler: { succeeded, info in
        if let localIdentifier = localIdentifier, let asset = Fetcher.fetchAsset(localIdentifier) {
          completion(Video(asset: asset), outputURL)
        } else {
          completion(nil, outputURL)
        }
    })
  }
}
