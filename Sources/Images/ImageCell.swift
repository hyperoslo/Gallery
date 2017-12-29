import UIKit
import Photos

class ImageCell: UICollectionViewCell {
    
    lazy var imageView: UIImageView = self.makeImageView()
    lazy var highlightOverlay: UIView = self.makeHighlightOverlay()
    lazy var frameView: FrameView = self.makeFrameView()
//    lazy var cloudView: UIImageView = self.makeImageView()
    lazy var progressView: MaskProgressView = self.makeMaskProgressView()
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Highlight
    
    override var isHighlighted: Bool {
        didSet {
            highlightOverlay.isHidden = !isHighlighted
        }
    }
    
    // MARK: - Config
    
    func configure(_ asset: PHAsset) {
        imageView.layoutIfNeeded()
        imageView.g_loadImage(asset)
    }
    
    func configure(_ image: Image) {
        if image.assetImageDataStorageLocation == .icloud {
            progressView.isHidden = false
        }
        else {
            progressView.isHidden = true
        }
        configure(image.asset)
        
    }
    
    // MARK: - Setup
    
    func setup() {
        [imageView, frameView, highlightOverlay,progressView].forEach {
            self.contentView.addSubview($0)
        }
        
        imageView.g_pinEdges()
        frameView.g_pinEdges()
        highlightOverlay.g_pinEdges()
        
        
        progressView.g_pin(on: .right)
        progressView.g_pin(on: .top)
        progressView.g_pin(size: CGSize(width: 30.0, height: 30.0))
//        progressView.g_pin(on: .top, view: progressView.superview)
        
    }
    
    // MARK: - Controls
    
    func makeImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }
    
    func makeHighlightOverlay() -> UIView {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.backgroundColor = Config.Grid.FrameView.borderColor.withAlphaComponent(0.3)
        view.isHidden = true
        
        return view
    }
    
    func makeFrameView() -> FrameView {
        let frameView = FrameView(frame: .zero)
        frameView.alpha = 0
        
        return frameView
    }
    
    func makeMaskProgressView() -> MaskProgressView {
        
        let maskprg = MaskProgressView(withMaskImage: GalleryBundle.image("gallery_cloud")!)
        maskprg.hightLightColor = Config.Grid.FrameView.borderColor
        return maskprg
    }
    
}
