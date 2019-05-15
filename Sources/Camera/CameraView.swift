import UIKit
import AVFoundation

protocol CameraViewDelegate: class {
  func cameraView(_ cameraView: CameraView, didTouch point: CGPoint)
}

class CameraView: UIView, UIGestureRecognizerDelegate {
    
  lazy var flashButton: TripleButton = self.makeFlashButton()
  lazy var rotateButton: UIButton = self.makeRotateButton()
  fileprivate lazy var bottomContainer: UIView = self.makeBottomContainer()
  lazy var bottomView: UIView = self.makeBottomView()
  lazy var shutterButton: ShutterButton = self.makeShutterButton()
  lazy var focusImageView: UIImageView = self.makeFocusImageView()
  lazy var tapGR: UITapGestureRecognizer = self.makeTapGR()
  lazy var rotateOverlayView: UIView = self.makeRotateOverlayView()
  lazy var shutterOverlayView: UIView = self.makeShutterOverlayView()
  lazy var blurView: UIVisualEffectView = self.makeBlurView()

  var timer: Timer?
  var previewLayer: AVCaptureVideoPreviewLayer?
  weak var delegate: CameraViewDelegate?

  // MARK: - Initialization

  override init(frame: CGRect) {
    super.init(frame: frame)

    backgroundColor = UIColor.black
    setup()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Setup

  func setup() {
    addGestureRecognizer(tapGR)

    [rotateButton, bottomContainer].forEach {
      addSubview($0)
    }

    [bottomView, shutterButton].forEach {
      bottomContainer.addSubview($0)
    }

    [flashButton, rotateButton].forEach {
      $0.g_addShadow()
    }

    rotateOverlayView.addSubview(blurView)
    insertSubview(rotateOverlayView, belowSubview: rotateButton)
    insertSubview(focusImageView, belowSubview: bottomContainer)
    insertSubview(shutterOverlayView, belowSubview: bottomContainer)

    bottomContainer.g_pinDownward()
    bottomContainer.g_pin(height: 101)
    bottomView.g_pinEdges()


    shutterButton.g_pinCenter()
    shutterButton.g_pin(size: CGSize(width: 60, height: 60))

//    rotateOverlayView.g_pinEdges()
    
    rotateOverlayView.g_pin(on: .top, constant: 51)
    rotateOverlayView.g_pin(on: .left)
    rotateOverlayView.g_pin(on: .right)
    rotateOverlayView.g_pin(on: .bottom, constant: 101)
    
    rotateOverlayView.g_pin(on: .top, constant: 51)
    rotateOverlayView.g_pin(on: .left)
    rotateOverlayView.g_pin(on: .right)
    rotateOverlayView.g_pin(on: .bottom, constant: 101)
    
    blurView.g_pinEdges()
//    shutterOverlayView.g_pinEdges()
    
    shutterOverlayView.g_pin(on: .top, constant: 51)
    shutterOverlayView.g_pin(on: .left)
    shutterOverlayView.g_pin(on: .right)
    shutterOverlayView.g_pin(on: .bottom, constant: 101)
    
    addSubview(flashButton)
    flashButton.g_pin(on: .centerY, view: shutterButton)
    flashButton.g_pin(on: .left, constant: 10)
    flashButton.g_pin(size: CGSize(width: 60, height: 44))
    
    addSubview(rotateButton)
    rotateButton.g_pin(on: .centerY, view: shutterButton)
    rotateButton.g_pin(on: .right)
    rotateButton.g_pin(size: CGSize(width: 44, height: 44))
    
  }

  func setupPreviewLayer(_ session: AVCaptureSession) {
    guard previewLayer == nil else { return }

    let layer = AVCaptureVideoPreviewLayer(session: session)
    layer.autoreverses = true
    layer.videoGravity = .resizeAspectFill
    layer.connection?.videoOrientation = Utils.videoOrientation()
    
    self.layer.insertSublayer(layer, at: 0)
    
    layer.frame = previewFrame

    previewLayer = layer
  }
    
    var previewFrame: CGRect {
        return CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height - 101)
    }

  override func layoutSubviews() {
    super.layoutSubviews()

    previewLayer?.frame = previewFrame
  }

  // MARK: - Action

  @objc func viewTapped(_ gr: UITapGestureRecognizer) {
    let point = gr.location(in: self)

    focusImageView.transform = CGAffineTransform.identity
    timer?.invalidate()
    delegate?.cameraView(self, didTouch: point)

    focusImageView.center = point

    UIView.animate(withDuration: 0.5, animations: {
      self.focusImageView.alpha = 1
      self.focusImageView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
    }, completion: { _ in
      self.timer = Timer.scheduledTimer(timeInterval: 1, target: self,
        selector: #selector(CameraView.timerFired(_:)), userInfo: nil, repeats: false)
    })
  }

  // MARK: - Timer

  @objc func timerFired(_ timer: Timer) {
    UIView.animate(withDuration: 0.3, animations: {
      self.focusImageView.alpha = 0
    }, completion: { _ in
      self.focusImageView.transform = CGAffineTransform.identity
    })
  }

  // MARK: - Controls

  func makeCloseButton() -> UIButton {
    let button = UIButton(type: .custom)
    button.setImage(GalleryBundle.image("gallery_close"), for: UIControl.State())

    return button
  }

  func makeFlashButton() -> TripleButton {
    let states: [TripleButton.ButtonState] = [
      TripleButton.ButtonState(title: "Gallery.Camera.Flash.Off".g_localize(fallback: "OFF"), image: GalleryBundle.image("gallery_camera_flash_off")!),
      TripleButton.ButtonState(title: "Gallery.Camera.Flash.On".g_localize(fallback: "ON"), image: GalleryBundle.image("gallery_camera_flash_on")!),
      TripleButton.ButtonState(title: "Gallery.Camera.Flash.Auto".g_localize(fallback: "AUTO"), image: GalleryBundle.image("gallery_camera_flash_auto")!)
    ]

    let button = TripleButton(states: states)

    return button
  }

  func makeRotateButton() -> UIButton {
    let button = UIButton(type: .custom)
    button.setImage(GalleryBundle.image("gallery_camera_rotate"), for: UIControl.State())

    return button
  }

  func makeBottomContainer() -> UIView {
    let view = UIView()

    return view
  }

  func makeBottomView() -> UIView {
    let view = UIView()
    view.backgroundColor = Config.Camera.BottomContainer.backgroundColor
    view.alpha = 0

    return view
  }

  func makeStackView() -> StackView {
    let view = StackView()

    return view
  }

  func makeShutterButton() -> ShutterButton {
    let button = ShutterButton()
    button.g_addShadow()

    return button
  }

  func makeDoneButton() -> UIButton {
    let button = UIButton(type: .system)
    button.setTitleColor(UIColor.white, for: UIControl.State())
    button.setTitleColor(UIColor.lightGray, for: .disabled)
    button.titleLabel?.font = Config.Font.Text.regular.withSize(16)
    button.setTitle("Gallery.Done".g_localize(fallback: "Done"), for: UIControl.State())

    return button
  }

  func makeFocusImageView() -> UIImageView {
    let view = UIImageView()
    view.frame.size = CGSize(width: 110, height: 110)
    view.image = GalleryBundle.image("gallery_camera_focus")
    view.backgroundColor = .clear
    view.alpha = 0

    return view
  }

  func makeTapGR() -> UITapGestureRecognizer {
    let gr = UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:)))
    gr.delegate = self

    return gr
  }

  func makeRotateOverlayView() -> UIView {
    let view = UIView()
    view.alpha = 0

    return view
  }

  func makeShutterOverlayView() -> UIView {
    let view = UIView()
    view.alpha = 0
    view.backgroundColor = UIColor.black

    return view
  }

  func makeBlurView() -> UIVisualEffectView {
    let effect = UIBlurEffect(style: .dark)
    let blurView = UIVisualEffectView(effect: effect)

    return blurView
  }
}
