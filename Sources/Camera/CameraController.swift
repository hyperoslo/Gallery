import UIKit
import AVFoundation

class CameraController: UIViewController {

  var locationManager: LocationManager?
  lazy var cameraMan: CameraMan = self.makeCameraMan()
  lazy var cameraView: CameraView = self.makeCameraView()
  let once = Once()
  let cart: Cart

  // MARK: - Init

  public required init(cart: Cart) {
    self.cart = cart
    super.init(nibName: nil, bundle: nil)
    cart.delegates.add(self)
  }

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Life cycle

  override func viewDidLoad() {
    super.viewDidLoad()

    setup()
    setupLocation()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    locationManager?.start()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    locationManager?.stop()
  }

  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    coordinator.animate(alongsideTransition: { _ in
      if let connection = self.cameraView.previewLayer?.connection,
        connection.isVideoOrientationSupported {
        connection.videoOrientation = Utils.videoOrientation()
      }
    }, completion: nil)

    super.viewWillTransition(to: size, with: coordinator)
  }

  // MARK: - Setup

  func setup() {
    view.addSubview(cameraView)
    cameraView.g_pinEdges()

    cameraView.flashButton.addTarget(self, action: #selector(flashButtonTouched(_:)), for: .touchUpInside)
    cameraView.rotateButton.addTarget(self, action: #selector(rotateButtonTouched(_:)), for: .touchUpInside)
    cameraView.shutterButton.addTarget(self, action: #selector(shutterButtonTouched(_:)), for: .touchUpInside)
  }

  func setupLocation() {
    if Config.Camera.recordLocation {
      locationManager = LocationManager()
    }
  }

  // MARK: - Action

  @objc func closeButtonTouched(_ button: UIButton) {
    EventHub.shared.close?()
  }

  @objc func flashButtonTouched(_ button: UIButton) {
    cameraView.flashButton.toggle()

    if let flashMode = AVCaptureDevice.FlashMode(rawValue: cameraView.flashButton.selectedIndex) {
      cameraMan.flash(flashMode)
    }
  }

  @objc func rotateButtonTouched(_ button: UIButton) {
    UIView.animate(withDuration: 0.3, animations: {
      self.cameraView.rotateOverlayView.alpha = 1
    }, completion: { _ in
      self.cameraMan.switchCamera {
        UIView.animate(withDuration: 0.7, animations: {
          self.cameraView.rotateOverlayView.alpha = 0
        }) 
      }
    })
  }

  @objc func stackViewTouched(_ stackView: StackView) {
    EventHub.shared.stackViewTouched?()
  }
    
    

  @objc func shutterButtonTouched(_ button: ShutterButton) {
    
    
    
//    guard isBelowImageLimit() else { return }
//    guard let previewLayer = cameraView.previewLayer else { return }
//
//    button.isEnabled = false
//    UIView.animate(withDuration: 0.1, animations: {
//      self.cameraView.shutterOverlayView.alpha = 1
//    }, completion: { _ in
//      UIView.animate(withDuration: 0.1, animations: {
//        self.cameraView.shutterOverlayView.alpha = 0
//      })
//    })
//
////    self.cameraView.stackView.startLoading()
//    cameraMan.takePhoto(previewLayer, location: locationManager?.latestLocation) { [weak self] asset in
//      guard let strongSelf = self else {
//        return
//      }
//
//      button.isEnabled = true
////      strongSelf.cameraView.stackView.stopLoading()
//
//      if let asset = asset {
//        strongSelf.cart.add(Image(asset: asset), newlyTaken: true)
//      }
//    }
  }

  @objc func doneButtonTouched(_ button: UIButton) {
    EventHub.shared.doneWithImages?()
  }
    
  fileprivate func isBelowImageLimit() -> Bool {
    return (Config.Camera.imageLimit == 0 || Config.Camera.imageLimit > cart.images.count)
    }
    
  // MARK: - View

  // MARK: - Controls

  func makeCameraMan() -> CameraMan {
    let man = CameraMan()
    man.delegate = self

    return man
  }

  func makeCameraView() -> CameraView {
    let view = CameraView()
    view.delegate = self

    return view
  }
}

extension CameraController: CartDelegate {

  func cart(_ cart: Cart, didAdd image: Image, newlyTaken: Bool) { }

  func cart(_ cart: Cart, didRemove image: Image) { }

  func cartDidReload(_ cart: Cart) { }
}

extension CameraController: PageAware {

  func pageDidShow() {
    once.run {
      cameraMan.setup()
    }
  }
}

extension CameraController: CameraViewDelegate {

  func cameraView(_ cameraView: CameraView, didTouch point: CGPoint) {
    cameraMan.focus(point)
  }
}

extension CameraController: CameraManDelegate {

  func cameraManDidStart(_ cameraMan: CameraMan) {
    cameraView.setupPreviewLayer(cameraMan.session)
  }

  func cameraManNotAvailable(_ cameraMan: CameraMan) {
    cameraView.focusImageView.isHidden = true
  }

  func cameraMan(_ cameraMan: CameraMan, didChangeInput input: AVCaptureDeviceInput) {
    cameraView.flashButton.isHidden = !input.device.hasFlash
  }
}
