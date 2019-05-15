//
//  CameraBottomView.swift
//  Gallery-iOS
//
//  Created by Muhammed Azharudheen on 4/21/19.
//  Copyright © 2019 Hyper Interaktiv AS. All rights reserved.
//

import UIKit

class CameraBottomView: UIView {
    
    var shouldHideFlashButton: Bool = false {
        didSet {
            buttonFlash.isHidden = shouldHideFlashButton
        }
    }
    
    enum Mode {
        case enabled
        case disabled
        
        var selectedFlashImage: UIImage {
            switch self {
            case .enabled: return GalleryBundle.image("flashon")!
            case .disabled: return GalleryBundle.image("flashdisabled")!
            }
        }
        
        var flashImage: UIImage {
            switch self {
            case .enabled: return GalleryBundle.image("flash_auto")!
            case .disabled: return GalleryBundle.image("flashdisabled")!
            }
        }
        
        var cameraImage: UIImage {
            switch self {
            case .enabled: return GalleryBundle.image("camera_button")!
            case .disabled: return GalleryBundle.image("camera_disabled")!
            }
        }
        
        var videoImage: UIImage {
            switch self {
            case .enabled: return GalleryBundle.image("video")!
            case .disabled: return GalleryBundle.image("video")!
            }
        }
        
        var selfie: UIImage {
            switch self {
            case .enabled: return GalleryBundle.image("selfie")!
            case .disabled: return GalleryBundle.image("selfiedisabled")!
            }
        }
    }
    
    var mode: Mode = .enabled {
        didSet {
            enableDisable()
        }
    }
    
    func enableDisable() {
        buttonCamera.setImage(mode.cameraImage, for: .normal)
        buttonVideo.setImage(mode.videoImage, for: .normal)
        buttonFlash.setImage(mode.flashImage, for: .normal)
        buttonFlash.setImage(mode.selectedFlashImage, for: .selected)
        buttonToggleCamera.setImage(mode.selfie, for: .normal)
        [buttonCamera, buttonFlash, buttonToggleCamera].forEach { $0.isUserInteractionEnabled = mode == .enabled }
    }
    
    typealias ButtonActionHandler = (UIButton) -> ()
    
    var didTapToggleCamera: ButtonActionHandler?
    var didTapCamera: ButtonActionHandler?
    var didTapCaptureVideo: ButtonActionHandler?
    var didTapbuttonFlash: ButtonActionHandler?
    
    var isRecording: Bool = false {
        didSet {
            buttonFlash.isHidden = isRecording
            buttonToggleCamera.isHidden = isRecording
        }
    }
    
    var mediaType: ArdhiCameraController.MediaType = .camera {
        didSet {
            updateMode()
        }
    }

    
    private lazy var buttonCamera = makeCameraButton()
    private lazy var buttonVideo = makeVideoButton()
    private lazy var buttonFlash = makeFlashButton()
    private lazy var buttonToggleCamera = makeToggleCameraButton()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
        setupActions()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setupActions()
    }
    
    func setup() {
        
        backgroundColor = UIColor.black
        
        addSubview(buttonCamera)
        buttonCamera.g_pinCenter()
        buttonCamera.g_pin(size: CGSize(width: 66, height: 66))
        
        addSubview(buttonVideo)
        buttonVideo.g_pinCenter()
        
        addSubview(buttonFlash)
        buttonFlash.g_pin(on: .left, constant: 16)
        buttonFlash.g_pin(on: .centerY)
        buttonFlash.g_pin(size: CGSize(width: 28, height: 28))
        
        addSubview(buttonToggleCamera)
        buttonToggleCamera.g_pin(on: .right, constant: -16)
        buttonToggleCamera.g_pin(on: .centerY)
        buttonToggleCamera.g_pin(size: CGSize(width: 40, height: 40))
    }
    
    func setupActions() {
        buttonToggleCamera.addTarget(self, action: #selector(buttonToggleCameraTapped(_:)), for: .touchUpInside)
        buttonVideo.addTarget(self, action: #selector(buttonVideoTapped(_:)), for: .touchUpInside)
        buttonCamera.addTarget(self, action: #selector(buttonCameraTapped(_:)), for: .touchUpInside)
        buttonFlash.addTarget(self, action: #selector(buttonFlashTapped(_:)), for: .touchUpInside)
    }
}

private extension CameraBottomView {
    
    private func updateMode() {
        buttonCamera.isHidden = mediaType == .video
        buttonVideo.isHidden = mediaType == .camera
    }
}

private extension CameraBottomView {
    
    func makeVideoButton() -> UIButton {
        let button = UIButton()
        button.setImage(GalleryBundle.image("video")!, for: .normal)
        return button
    }
    
    func makeCameraButton() -> UIButton {
        let button = UIButton()
        button.setImage(GalleryBundle.image("camera_button")!, for: .normal)
        return button
    }
    
    func makeFlashButton() -> UIButton {
        let button = UIButton()
        button.setImage(GalleryBundle.image("flash_auto")!, for: .normal)
        button.setImage(GalleryBundle.image("flashon")!, for: .selected)
        return button
    }
    
    func makeToggleCameraButton() -> UIButton {
        let button = UIButton()
        button.setImage(GalleryBundle.image("selfie")!, for: .normal)
        return button
    }
}

private extension CameraBottomView {
    
    @objc
    func buttonVideoTapped(_ sender: UIButton) {
        didTapCaptureVideo?(sender)
    }
    
    @objc
    func buttonCameraTapped(_ sender: UIButton) {
        didTapCamera?(sender)
    }
    
    @objc
    func buttonFlashTapped(_ sender: UIButton) {
        didTapbuttonFlash?(sender)
    }
    
    @objc
    func buttonToggleCameraTapped(_ sender: UIButton) {
        didTapToggleCamera?(sender)
    }
}
