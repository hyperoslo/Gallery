import Foundation
import AVFoundation
import PhotosUI
import Photos

protocol CameraManDelegate: class {
  func cameraManNotAvailable(cameraMan: CameraMan)
  func cameraManDidStart(cameraMan: CameraMan)
  func cameraMan(cameraMan: CameraMan, didChangeInput input: AVCaptureDeviceInput)
}

class CameraMan {
  weak var delegate: CameraManDelegate?

  let session = AVCaptureSession()
  let queue = dispatch_queue_create("no.hyper.Gallery.Camera.SessionQueue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0))
  let savingQueue = dispatch_queue_create("no.hyper.Gallery.Camera.SavingQueue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_BACKGROUND, 0))

  var backCamera: AVCaptureDeviceInput?
  var frontCamera: AVCaptureDeviceInput?
  var stillImageOutput: AVCaptureStillImageOutput?

  deinit {
    stop()
  }

  // MARK: - Setup

  func setup() {
    checkPermission()
  }

  func setupDevices() {
    // Input
    AVCaptureDevice
      .devices().flatMap {
        return $0 as? AVCaptureDevice
      }.filter {
        return $0.hasMediaType(AVMediaTypeVideo)
      }.forEach {
        switch $0.position {
        case .Front:
          self.frontCamera = try? AVCaptureDeviceInput(device: $0)
        case .Back:
          self.backCamera = try? AVCaptureDeviceInput(device: $0)
        default:
          break
        }
    }

    // Output
    stillImageOutput = AVCaptureStillImageOutput()
    stillImageOutput?.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
  }

  func addInput(input: AVCaptureDeviceInput) {
    configurePreset(input)

    if session.canAddInput(input) {
      session.addInput(input)

      Dispatch.main {
        self.delegate?.cameraMan(self, didChangeInput: input)
      }
    }
  }

  // MARK: - Permission

  func checkPermission() {
    let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)

    switch status {
    case .Authorized:
      start()
    case .NotDetermined:
      requestPermission()
    default:
      delegate?.cameraManNotAvailable(self)
    }
  }

  func requestPermission() {
    AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo) { granted in
      Dispatch.main {
        if granted {
          self.start()
        } else {
          self.delegate?.cameraManNotAvailable(self)
        }
      }
    }
  }

  // MARK: - Session

  var currentInput: AVCaptureDeviceInput? {
    return session.inputs.first as? AVCaptureDeviceInput
  }

  private func start() {
    // Devices
    setupDevices()

    guard let input = backCamera, output = stillImageOutput else { return }

    addInput(input)

    if session.canAddOutput(output) {
      session.addOutput(output)
    }

    Dispatch.on(queue) {
      self.session.startRunning()

      Dispatch.main {
        self.delegate?.cameraManDidStart(self)
      }
    }
  }

  func stop() {
    self.session.stopRunning()
  }

  func switchCamera(completion: (() -> Void)? = nil) {
    guard let currentInput = currentInput
      else {
        completion?()
        return
    }

    Dispatch.on(queue) {
      guard let input = (currentInput == self.backCamera) ? self.frontCamera : self.backCamera
        else {
          Dispatch.main {
            completion?()
          }
          return
      }

      self.configure {
        self.session.removeInput(currentInput)
        self.addInput(input)
      }

      Dispatch.main {
        completion?()
      }
    }
  }

  func takePhoto(previewLayer: AVCaptureVideoPreviewLayer, location: CLLocation?, completion: ((PHAsset?) -> Void)) {
    guard let connection = stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo) else { return }

    connection.videoOrientation = Utils.videoOrientation()

    Dispatch.on(queue) {
      self.stillImageOutput?.captureStillImageAsynchronouslyFromConnection(connection) {
        buffer, error in

        guard error == nil && buffer != nil && CMSampleBufferIsValid(buffer),
          let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer),
          image = UIImage(data: imageData)
          else {
            Dispatch.main {
              completion(nil)
            }
            return
        }

        self.savePhoto(image, location: location, completion: completion)
      }
    }
  }

  func savePhoto(image: UIImage, location: CLLocation?, completion: ((PHAsset?) -> Void)) {
    var localIdentifier: String?

    Dispatch.on(savingQueue) {
      do {
        try PHPhotoLibrary.sharedPhotoLibrary().performChangesAndWait {
          let request = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
          localIdentifier = request.placeholderForCreatedAsset?.localIdentifier

          request.creationDate = NSDate()
          request.location = location
        }

        Dispatch.main {
          if let localIdentifier = localIdentifier {
            completion(Fetcher.fetchAsset(localIdentifier))
          } else {
            completion(nil)
          }
        }
      } catch {
        Dispatch.main {
          completion(nil)
        }
      }
    }
  }

  func flash(mode: AVCaptureFlashMode) {
    guard let device = currentInput?.device where device.isFlashModeSupported(mode) else { return }

    Dispatch.on(queue) {
      self.lock {
        device.flashMode = mode
      }
    }
  }

  func focus(point: CGPoint) {
    guard let device = currentInput?.device where device.isFocusModeSupported(AVCaptureFocusMode.Locked) else { return }

    Dispatch.on(queue) {
      self.lock {
        device.focusPointOfInterest = point
      }
    }
  }

  // MARK: - Lock

  func lock(block: () -> Void) {
    if let device = currentInput?.device where (try? device.lockForConfiguration()) != nil {
      block()
      device.unlockForConfiguration()
    }
  }

  // MARK: - Configure
  func configure(block: () -> Void) {
    session.beginConfiguration()
    block()
    session.commitConfiguration()
  }

  // MARK: - Preset

  func configurePreset(input: AVCaptureDeviceInput) {
    for asset in preferredPresets() {
      if input.device.supportsAVCaptureSessionPreset(asset) && self.session.canSetSessionPreset(asset) {
        self.session.sessionPreset = asset
        return
      }
    }
  }

  func preferredPresets() -> [String] {
    return [
      AVCaptureSessionPresetHigh,
      AVCaptureSessionPresetMedium,
      AVCaptureSessionPresetLow
    ]
  }
}