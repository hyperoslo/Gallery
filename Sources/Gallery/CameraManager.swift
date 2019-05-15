//
//  CameraManager.swift
//  Gallery-iOS
//
//  Created by Muhammed Azharudheen on 4/24/19.
//  Copyright © 2019 Hyper Interaktiv AS. All rights reserved.
//

import AVFoundation
import AVKit


class CameraManager: NSObject {
    
    var mediaType: ArdhiCameraController.MediaType = .camera
    
    var isFlashEnabled = false {
        didSet {
            guard cameraPosition == .back, let input = activeInput, mediaType == .video else { return }
            setTorchMode(isFlashEnabled ? .on : .off, for: input.device)
        }
    }
    
    var isFlashAvailable: ((Bool) -> ())?
    
    var cameraPosition: CameraPosition = .back {
        didSet {
            switchCamera()
        }
    }
    
    func switchCamera() {
        captureSession.beginConfiguration()
        guard let input = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition.position),
            let newInput = try? AVCaptureDeviceInput(device: input) else { return }
        captureSession.inputs.forEach { captureSession.removeInput($0) }
        
        if captureSession.canAddInput(newInput) {
            captureSession.addInput(newInput)
            activeInput = newInput
        }
        captureSession.commitConfiguration()
    }
    
    typealias PhotoCaptureCompletionBlock = ((UIImage?, Error?) -> Void)
    var didCapturedPhoto: PhotoCaptureCompletionBlock?
    
    typealias VideoCaptureStartedBlock = (() -> Void)
    var didStartedVideoCapturing: VideoCaptureStartedBlock?
    
    typealias VideoCaptureCompletionBlock = ((URL?, Error?) -> Void)
    var didCapturedVideo: VideoCaptureCompletionBlock?

    private var tempFilePath: URL = {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0] as String
        let filePath: String = "\(documentsDirectory)/video.mp4"
        if FileManager.default.fileExists(atPath: filePath) {
            try? FileManager.default.removeItem(atPath: filePath)
        }
        return URL(fileURLWithPath: filePath)
    }()
    
    private var activeInput: AVCaptureDeviceInput? {
        didSet {
            updatedDevice()
        }
    }
    
    private let captureSession = AVCaptureSession()
    private let movieOutput = AVCaptureMovieFileOutput()
   
    private var cameraOutput: AVCapturePhotoOutput?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var viewPreview: UIView
    
    func updatedDevice() {
        guard let activeDevice = activeInput?.device else { return }
        switch cameraPosition {
        case .front: isFlashAvailable?(activeDevice.isFlashAvailable)
        case .back: isFlashAvailable?(activeDevice.isTorchModeSupported(.on))
        }
    }
    
    init(previewView: UIView, position: CameraPosition = .back) {
        self.viewPreview = previewView
        self.cameraPosition = position
        super.init()
        initiateCamera()
    }
    
    func updateFrame() {
        previewLayer?.frame = viewPreview.layer.bounds
    }
}

// Initiating camera
private extension CameraManager {
    
    private func initiateCamera() {
        if setupSession() {
            setupPreview()
            startSession()
        }
    }
    
    func setupSession() -> Bool {
        
        captureSession.sessionPreset = AVCaptureSession.Preset.high
        
        // Setup Camera
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: cameraPosition.position) else { return  false }
        
        do {
            
            let input = try AVCaptureDeviceInput(device: camera)
            
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
            }
        } catch {
            print("Error setting device video input: \(error)")
            return false
        }
        
       /* // Setup Microphone
        let microphone = AVCaptureDevice.default(for: AVMediaType.audio)!
        
        do {
            let micInput = try AVCaptureDeviceInput(device: microphone)
            if captureSession.canAddInput(micInput) {
                captureSession.addInput(micInput)
            }
        } catch {
            print("Error setting device audio input: \(error)")
            return false
        }  */
        
        cameraOutput = AVCapturePhotoOutput()
        
        if let output = cameraOutput, captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        
        // Movie output
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
        
        return true
    }
    
    func setupPreview() {
        // Configure previewLayer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        DispatchQueue.main.async {
            self.previewLayer?.frame = self.viewPreview.layer.bounds
            self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            if let layer = self.previewLayer {
                self.viewPreview.layer.addSublayer(layer)
            }
        }
    }
    
    func startSession() {
        
        if !captureSession.isRunning {
            videoQueue().async {
                self.captureSession.startRunning()
            }
        }
    }
    
    func videoQueue() -> DispatchQueue {
        return DispatchQueue.main
    }
    
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation
        
        switch UIDevice.current.orientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
        case .landscapeRight:
            orientation = AVCaptureVideoOrientation.landscapeLeft
        case .portraitUpsideDown:
            orientation = AVCaptureVideoOrientation.portraitUpsideDown
        default:
            orientation = AVCaptureVideoOrientation.landscapeRight
        }
        
        return orientation
    }
    
    func setTorchMode(_ torchMode: AVCaptureDevice.TorchMode, for device: AVCaptureDevice) {
        if device.isTorchModeSupported(torchMode) && device.torchMode != torchMode {
            do
            {
                try device.lockForConfiguration()
                device.torchMode = torchMode
                device.unlockForConfiguration()
            }
            catch {
                print("Error:-\(error)")
            }
        }
    }
    
}

private extension CameraManager {
    
    func startVideoRecording() {
        let connection = movieOutput.connection(with: AVMediaType.video)
        
        if (connection?.isVideoOrientationSupported)! {
            connection?.videoOrientation = currentVideoOrientation()
        }
        
        if (connection?.isVideoStabilizationSupported)! {
            connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
        }

        movieOutput.startRecording(to: tempFilePath, recordingDelegate: self)
    }
    
    func stopVideoRecording() {
        if movieOutput.isRecording == true {
            movieOutput.stopRecording()
        }
    }
    
    func takePhoto() {
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isHighResolutionPhotoEnabled = false
        
        if let input = activeInput, input.device.hasFlash, isFlashEnabled {
            photoSettings.flashMode = .on
        } else {
            photoSettings.flashMode = .off
        }
        
        if let firstAvailablePreviewPhotoPixelFormatTypes = photoSettings.availablePreviewPhotoPixelFormatTypes.first {
            photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: firstAvailablePreviewPhotoPixelFormatTypes]
        }
        cameraOutput?.capturePhoto(with: photoSettings, delegate: self)
    }
}

extension CameraManager: AVCaptureFileOutputRecordingDelegate, AVCapturePhotoCaptureDelegate {
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        didStartedVideoCapturing?()
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        guard error == nil else {
            didCapturedVideo?(nil, error)
            return
        }
        didCapturedVideo?(outputFileURL, nil)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation() , let image = UIImage(data: imageData) else {
            didCapturedPhoto?(nil, error)
            return
        }
        didCapturedPhoto?(image, nil)
    }
}

// MARK: outside functions to capture photo and video
extension CameraManager {
    
    func capturePhoto() {
        takePhoto()
    }
    
    func captureVideo() {
        guard !movieOutput.isRecording else {
            stop()
            return
        }
        startVideoRecording()
    }
    
    func stop() {
        stopVideoRecording()
    }
}

extension CameraManager {
    enum CameraPosition {
        case back, front
        
        mutating func toggle() {
            switch self {
            case .back: self = .front
            case .front: self = .back
            }
        }
        
        var position: AVCaptureDevice.Position {
            switch self {
            case .back: return .back
            case .front: return .front
            }
        }
    }
}
