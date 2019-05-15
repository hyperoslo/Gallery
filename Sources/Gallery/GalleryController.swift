import UIKit
import AVKit
import AVFoundation

public protocol GalleryControllerDelegate: class {
    func galleryController(_ controller: GalleryController, didfinish withImage: UIImage)
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video)
    func galleryControllerDidCancel(_ controller: GalleryController)
}

open class GalleryController: UIViewController {
    
    public var initialTab: Tabs = .library
    
    public enum Tabs{
        case library
        case photo
    }
    
    // MARK: - Init
    public required init() {
        super.init(nibName: nil, bundle: nil)
        configureGallery()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override var prefersStatusBarHidden : Bool {
        return false
    }
    
    open func configureGallery() { }
    
    public let cart = Cart()
    
    var galleryMode: GalleryMode = .cameraUnselected {
        didSet {
            updateTopAndPreviewView()
        }
    }
    
    let containerView = UIView()
    let topView = TopView()
    let bottomView = BottomView()
    
    public weak var delegate: GalleryControllerDelegate?
    
    private lazy var imageController : ImagesController = {
        let controller = ImagesController(cart: cart)
        return controller
    }()
    
    private lazy var cameraController: ArdhiCameraController = {
        let controller = ArdhiCameraController(cart: cart)
        return controller
    }()
    
    // MARK: - Life cycle

    open override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        setup()
        setupViews()
        setupActions()
        updateTopAndPreviewView()
        self.cameraController.mediaType = .camera
        if initialTab == .library {
            addChildController(imageController)
            bottomView.leftButton.isSelected = true
        } else if initialTab == .photo {
            addChildController(cameraController)
            bottomView.centerButton.isSelected = true
        }
    }
}

extension GalleryController {
    // MARK: - Setup
    func setup() {
        
        EventHub.shared.dismissPreview = {
            self.topView.mode = .cameraUnselected
        }
        
        EventHub.shared.close = { [weak self] in
            if let strongSelf = self {
                strongSelf.delegate?.galleryControllerDidCancel(strongSelf)
            }
        }
        
        EventHub.shared.capturedImage = { [weak self] in
            guard let welf = self, let image = welf.cart.image, let delegate = welf.delegate else {
                return
            }
            PreviewViewController.show(from: welf, cart: welf.cart, mode: .image(image: image), delegate: delegate)
        }
        
        EventHub.shared.capturedVideo = { [weak self] in
            guard let welf = self, let url = welf.cart.url, let delegate = welf.delegate else { return }
            PreviewViewController.show(from: welf, cart: welf.cart, mode: .video(video: url), delegate: delegate)
        }
        
        EventHub.shared.doneWithImages = { [weak self] in
            guard let welf = self, let img = welf.cart.images.first, let delegate = welf.delegate else { return }
            PreviewViewController.show(from: welf, cart: welf.cart, mode: .libraryImage(asset: img.asset), delegate: delegate)
        }
        
        EventHub.shared.doneWithVideos = { [weak self] in
            guard let welf = self, let video = welf.cart.video, let delegate = welf.delegate else { return }
            PreviewViewController.show(from: welf, cart: welf.cart, mode: .lbraryVideo(asset: video.asset), delegate: delegate)
        }
        
        EventHub.shared.finishedWithImage = { [weak self] in
            if let strongSelf = self, let image = strongSelf.cart.image {
                strongSelf.delegate?.galleryController(strongSelf, didfinish: image)
            }
        }
    }
}


private extension GalleryController {
    
    private func addChildController<T: UIViewController>(_ controller: T) where T : PageAware {
        if let ctrl = children.first {
            removeFromParentController(ctrl)
        }
        addChild(controller)
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
        controller.view.g_pinEdges()
        controller.pageDidShow()
    }
    
    func removeFromParentController(_ controller: UIViewController) {
        controller.willMove(toParent: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParent()
    }
}

private extension GalleryController {
    
    func setupViews() {
        view.addSubview(topView)
        
        let safeArea = view.safeAreaLayoutGuide
        topView.topAnchor.constraint(equalTo: safeArea.topAnchor).isActive = true
        topView.g_pin(on: .left)
        topView.g_pin(on: .right)
        
        view.addSubview(bottomView)
        bottomView.g_pin(on: .left)
        bottomView.g_pin(on: .right)
        bottomView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
        bottomView.g_pin(height: 44)
        
        view.addSubview(containerView)
        containerView.g_pin(on: .left)
        containerView.g_pin(on: .right)
        containerView.g_pin(on: .top, view: topView, on: .bottom)
        containerView.g_pin(on: .bottom, view: bottomView, on: .top)
    }
    
    func updateTopAndPreviewView() {
//        topView.mode = galleryMode
//        previewImageView.isHidden = !galleryMode.shouldShowPreviewScreen
    }
    
    func setupActions() {
        bottomView.didTapLeft = { [unowned self] in
            self.addChildController(self.imageController)
        }
        
        bottomView.didTapCenter = { [unowned self] in 
            self.cameraController.mediaType = .camera
            self.addChildController(self.cameraController)
        }
        
        bottomView.didTapRight = { [unowned self] in
            self.cameraController.mediaType = .video
            self.addChildController(self.cameraController)
        }
        
        topView.didTapRight = {
            EventHub.shared.doneWithImages?()
        }
        
        topView.didTapLeft = { [unowned self] in
            switch  self.galleryMode {
            case .cameraSelected:
                self.galleryMode = .cameraUnselected
                self.cameraController.viewBottom.mode = .enabled
                case .cameraUnselected, .photoLibrarySelected, .photoLibraryUnselected: EventHub.shared.close?()
            }
        }
    }
}

extension UIColor {
    static var bottomSeperatorColor: UIColor = UIColor(red: 74/255, green: 79/255, blue: 84/255, alpha: 1)
}
