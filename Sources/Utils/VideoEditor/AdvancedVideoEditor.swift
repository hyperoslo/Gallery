import Foundation
import AVFoundation
import Photos

public class AdvancedVideoEditor: VideoEditing {

  var writer: AVAssetWriter!
  var writerInput: AVAssetWriterInput!
  var reader: AVAssetReader!
  var readerOutput: AVAssetReaderOutput!

  // MARK: - Initialization

  public init() {

  }

  // MARK: - Crop

  public func crop(avAsset: AVAsset, completion: (NSURL?) -> Void) {
    guard let outputURL = EditInfo.outputURL() else {
      completion(nil)
      return
    }

    let writer = try? AVAssetWriter(URL: outputURL, fileType: EditInfo.file.type)
  
  }
}

