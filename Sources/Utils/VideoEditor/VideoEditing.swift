import UIKit
import AVFoundation
import Photos

public protocol VideoEditing: class {

  func crop(avAsset: AVAsset, completion: (NSURL?) -> Void)
  func edit(video: Video, completion: (video: Video?, tempPath: NSURL?) -> Void)
}

extension VideoEditing {

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
}