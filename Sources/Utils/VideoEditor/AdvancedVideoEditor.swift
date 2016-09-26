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

    self.writer = writer
    self.reader = reader

    wire(avAsset)

    writer.startWriting()
    reader.startReading()
    writer.startSessionAtSourceTime(kCMTimeZero)

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

    writer.finishWritingWithCompletionHandler {
      completion(outputURL)
    }
  }

  // MARK: - Helper

  private func wire(avAsset: AVAsset) {
    // Video
    let videoTracks = avAsset.tracksWithMediaType(AVMediaTypeVideo)
    if !videoTracks.isEmpty {
      // Output
      let videoOutput = AVAssetReaderVideoCompositionOutput(videoTracks: videoTracks, videoSettings: nil)
      videoOutput.videoComposition = EditInfo.composition(avAsset)
      if reader.canAddOutput(videoOutput) {
        reader.canAddOutput(videoOutput)
      }

      // Input
      let videoInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: nil)
      if writer.canAddInput(videoInput) {
        writer.addInput(videoInput)
      }

      self.videoInput = videoInput
      self.videoOutput = videoOutput
    }

    // Audio
    let audioTracks = avAsset.tracksWithMediaType(AVMediaTypeAudio)
    if !audioTracks.isEmpty {
      // Output
      let audioOutput = AVAssetReaderAudioMixOutput(audioTracks: audioTracks, audioSettings: nil)
      if reader.canAddOutput(audioOutput) {
        reader.addOutput(audioOutput)
      }

      // Input
      let audioInput = AVAssetWriterInput(mediaType: AVMediaTypeAudio, outputSettings: nil)
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

