//
//  ArdhiCameraController.swift
//  Gallery-iOS
//
//  Created by Muhammed Azharudheen on 4/21/19.
//  Copyright © 2019 Hyper Interaktiv AS. All rights reserved.
//

import UIKit
import AVFoundation

class ArdhiCameraController: UIViewController {
    
    var manager: CameraManager?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    convenience init(cart: Cart) {
        self.init(nibName: nil, bundle: nil)
        self.cart = cart
    }
    
    var cart = Cart()
    
    var mediaType: MediaType = .camera {
        didSet {
            viewBottom.mediaType = mediaType
            manager?.mediaType = mediaType
        }
    }

    lazy var viewBottom = makeBottomView()
    lazy var viewPreview = makePreviewView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupActions()
        
        if Permission.Camera.status != .authorized {
            Permission.Camera.request { [weak self] in
                guard Permission.Camera.status == .authorized else {
                    Alert.shared.show(from: self, mode: .camera)
                    return
                }
                self?.setupCamera()
            }
        } else {
            setupCamera()
        }
    }
    
    func setupCamera() {
        DispatchQueue.global().async {
            self.setupCameraManager()
            DispatchQueue.main.async { [weak self] in
                self?.setupCameraManagerActions()
            }
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        manager?.stop()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        manager?.updateFrame()
    }
}

private extension ArdhiCameraController {
    func setupViews() {
        
        view.addSubview(viewBottom)
        viewBottom.g_pin(on: .left)
        viewBottom.g_pin(on: .right)
        viewBottom.g_pin(on: .bottom)
        viewBottom.g_pin(height: 101)
        
        view.addSubview(viewPreview)
        viewPreview.g_pin(on: .left)
        viewPreview.g_pin(on: .top)
        viewPreview.g_pin(on: .right)
        viewPreview.g_pin(on: .bottom, view: viewBottom, on: .top)
    }
}

private extension ArdhiCameraController {
    
    func makePreviewView() -> UIView {
        let view = UIView()
        return view
    }
    
    func makeBottomView() -> CameraBottomView {
        let view = CameraBottomView()
        return view
    }
    
    func makeTimeLabel() -> UILabel {
        let lbl = UILabel()
        return lbl
    }
}

private extension ArdhiCameraController {
    
    func setupActions() {
        
        viewBottom.didTapbuttonFlash = { [unowned self] sender in
            print(sender.isSelected)
            sender.isSelected = !sender.isSelected
            print(sender.isSelected)
            self.manager?.isFlashEnabled = sender.isSelected
        }
        
        viewBottom.didTapCamera = { [unowned self] sender in
            self.manager?.capturePhoto()
        }
        
        viewBottom.didTapCaptureVideo = { [unowned self] sender in
            self.manager?.captureVideo()
        }
        
        viewBottom.didTapToggleCamera = { [unowned self] sender in
            self.manager?.cameraPosition.toggle()
        }
    }
}

extension ArdhiCameraController: PageAware {
    func pageDidShow() { }
    
    func setupCameraManager() {
        manager = CameraManager(previewView: viewPreview)
    }
    
    func setupCameraManagerActions() {
        manager?.didCapturedPhoto = { [weak self] image, error in
            guard let image = image else { return }
            self?.cart.reset()
            self?.cart.image = image
            EventHub.shared.capturedImage?()
        }
        manager?.didStartedVideoCapturing = { [weak self] in
            self?.viewBottom.mode = .disabled
        }
        manager?.didCapturedVideo = { [weak self] url, error in
            guard let welf = self, let url = url, welf.mediaType == .video else { return }
            welf.cart.reset()
            welf.cart.url = url
            EventHub.shared.capturedVideo?()
        }
        
        manager?.isFlashAvailable = { [weak self] flashAvailable in
            guard let welf = self else { return }
            welf.viewBottom.shouldHideFlashButton = !flashAvailable
        }
    }
}

extension ArdhiCameraController {
    enum MediaType {
        case camera
        case video
        case gallery
    }
}

extension UIViewController {
    func dismissController() {
        dismiss(animated: true)
    }
}
