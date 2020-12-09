import Foundation
import AVFoundation
import Photos

public class AdvancedVideoEditor: VideoEditing {
  var writer: AVAssetWriter!
  var videoInput: AVAssetWriterInput?
  var audioInput: AVAssetWriterInput?

  var reader: AVAssetReader!
  var videoOutput: AVAssetReaderVideoCompositionOutput?
  var audioOutput: AVAssetReaderAudioMixOutput?

  var audioCompleted: Bool = false
  var videoCompleted: Bool = false

  let requestQueue = DispatchQueue(label: "no.hyper.Gallery.AdvancedVideoEditor.RequestQueue", qos: .background)
  let finishQueue = DispatchQueue(label: "no.hyper.Gallery.AdvancedVideoEditor.FinishQueue", qos: .background)
  
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

    guard let writer = try? AVAssetWriter(outputURL: outputURL as URL, fileType: EditInfo.file.type),
      let reader = try? AVAssetReader(asset: avAsset)
    else {
      completion(nil)
      return
    }

    // Config
    writer.shouldOptimizeForNetworkUse = true

    self.writer = writer
    self.reader = reader

    wire(avAsset)

    // Start
    writer.startWriting()
    reader.startReading()
    writer.startSession(atSourceTime: CMTime.zero)

    // Video
    if let videoOutput = videoOutput, let videoInput = videoInput {
      videoInput.requestMediaDataWhenReady(on: requestQueue) {
        if !self.stream(from: videoOutput, to: videoInput) {
          self.finishQueue.async {
            self.videoCompleted = true
            if self.audioCompleted {
              self.finish(outputURL: outputURL, completion: completion)
            }
          }
        }
      }
    }

    // Audio
    if let audioOutput = audioOutput, let audioInput = audioInput {
      audioInput.requestMediaDataWhenReady(on: requestQueue) {
        if !self.stream(from: audioOutput, to: audioInput) {
          self.finishQueue.async {
            self.audioCompleted = true
            if self.videoCompleted {
              self.finish(outputURL: outputURL, completion: completion)
            }
          }
        }
      }
    }
  }

  // MARK: - Finish

  fileprivate func finish(outputURL: URL, completion: @escaping (URL?) -> Void) {
    if reader.status == .failed {
      writer.cancelWriting()
    }

    guard reader.status != .cancelled
      && reader.status != .failed
      && writer.status != .cancelled
      && writer.status != .failed
    else {
      completion(nil)
      return
    }

    writer.finishWriting {
      switch self.writer.status {
      case .completed:
        completion(outputURL)
      default:
        completion(nil)
      }
    }
  }

  // MARK: - Helper

  fileprivate func wire(_ avAsset: AVAsset) {
    wireVideo(avAsset)
    wireAudio(avAsset)
  }

  fileprivate func wireVideo(_ avAsset: AVAsset) {
    let videoTracks = avAsset.tracks(withMediaType: AVMediaType.video)
    if !videoTracks.isEmpty {
      // Output
      let videoOutput = AVAssetReaderVideoCompositionOutput(videoTracks: videoTracks, videoSettings: nil)
      videoOutput.videoComposition = EditInfo.composition(avAsset)
      if reader.canAdd(videoOutput) {
        reader.add(videoOutput)
      }

      // Input
      let videoInput = AVAssetWriterInput(mediaType: AVMediaType.video,
                                          outputSettings: EditInfo.videoSettings,
                                          sourceFormatHint: avAsset.g_videoDescription)
      if writer.canAdd(videoInput) {
        writer.add(videoInput)
      }

      self.videoInput = videoInput
      self.videoOutput = videoOutput
    }
  }

  fileprivate func wireAudio(_ avAsset: AVAsset) {
    let audioTracks = avAsset.tracks(withMediaType: AVMediaType.audio)
    if !audioTracks.isEmpty {
      // Output
      let audioOutput = AVAssetReaderAudioMixOutput(audioTracks: audioTracks, audioSettings: nil)
      audioOutput.alwaysCopiesSampleData = true
      if reader.canAdd(audioOutput) {
        reader.add(audioOutput)
      }

      // Input
      let audioInput = AVAssetWriterInput(mediaType: AVMediaType.audio,
                                          outputSettings: EditInfo.audioSettings,
                                          sourceFormatHint: avAsset.g_audioDescription)
      if writer.canAdd(audioInput) {
        writer.add(audioInput)
      }

      self.audioOutput = audioOutput
      self.audioInput = audioInput
    }
  }

  fileprivate func stream(from output: AVAssetReaderOutput, to input: AVAssetWriterInput) -> Bool {
    while input.isReadyForMoreMediaData {
      guard reader.status == .reading && writer.status == .writing,
        let buffer = output.copyNextSampleBuffer()
      else {
        input.markAsFinished()
        return false
      }

      return input.append(buffer)
    }

    return true
  }
}

