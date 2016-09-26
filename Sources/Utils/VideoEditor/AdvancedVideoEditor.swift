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

  let queue = dispatch_queue_create("no.hyper.Gallery.AdvancedVideoEditor.Queue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0))

  // MARK: - Initialization

  public init() {

  }

  // MARK: - Crop

  public func crop(avAsset: AVAsset, completion: (NSURL?) -> Void) {
    guard let outputURL = EditInfo.outputURL else {
      completion(nil)
      return
    }

    guard let writer = try? AVAssetWriter(URL: outputURL, fileType: EditInfo.file.type),
      reader = try? AVAssetReader(asset: avAsset)
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
    writer.startSessionAtSourceTime(kCMTimeZero)

    guard reader.status == .Reading && writer.status == .Writing
    else {
      completion(nil)
      return
    }

    // Video
    if let videoOutput = videoOutput, videoInput = videoInput {
      videoInput.requestMediaDataWhenReadyOnQueue(queue) {
        self.stream(from: videoOutput, to: videoInput)
      }
    }

    // Audio
    if let audioOutput = audioOutput, audioInput = audioInput {
      audioInput.requestMediaDataWhenReadyOnQueue(queue) {
        self.stream(from: audioOutput, to: audioInput)
      }
    }

    // Finish
    writer.finishWritingWithCompletionHandler {
      switch self.writer.status {
      case .Completed:
        completion(outputURL)
      default:
        completion(nil)
      }
    }
  }

  // MARK: - Helper

  private func wire(avAsset: AVAsset) {
    wireVideo(avAsset)
    wireAudio(avAsset)
  }

  private func wireVideo(avAsset: AVAsset) {
    let videoTracks = avAsset.tracksWithMediaType(AVMediaTypeVideo)
    if !videoTracks.isEmpty {
      // Output
      let videoOutput = AVAssetReaderVideoCompositionOutput(videoTracks: videoTracks, videoSettings: nil)
      videoOutput.videoComposition = EditInfo.composition(avAsset)
      if reader.canAddOutput(videoOutput) {
        reader.addOutput(videoOutput)
      }

      // Input
      let videoInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: EditInfo.videoSettings)
      if writer.canAddInput(videoInput) {
        writer.addInput(videoInput)
      }

      self.videoInput = videoInput
      self.videoOutput = videoOutput
    }
  }

  private func wireAudio(avAsset: AVAsset) {
    let audioTracks = avAsset.tracksWithMediaType(AVMediaTypeAudio)
    if !audioTracks.isEmpty {
      // Output
      let audioOutput = AVAssetReaderAudioMixOutput(audioTracks: audioTracks, audioSettings: nil)
      audioOutput.alwaysCopiesSampleData = true
      if reader.canAddOutput(audioOutput) {
        reader.addOutput(audioOutput)
      }

      // Input
      let audioInput = AVAssetWriterInput(mediaType: AVMediaTypeAudio, outputSettings: EditInfo.audioSettings)
      if writer.canAddInput(audioInput) {
        writer.addInput(audioInput)
      }

      self.audioOutput = audioOutput
      self.audioInput = audioInput
    }
  }

  private func stream(from output: AVAssetReaderOutput, to input: AVAssetWriterInput) {
    while input.readyForMoreMediaData {
      guard let buffer = output.copyNextSampleBuffer()
      else {
        input.markAsFinished()
        break
      }

      input.appendSampleBuffer(buffer)
    }
  }
}

