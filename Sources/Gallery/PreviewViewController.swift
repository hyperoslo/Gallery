//
//  PreviewViewController.swift
//  Gallery-iOS
//
//  Created by Muhammed Azharudheen on 4/25/19.
//  Copyright © 2019 Hyper Interaktiv AS. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import Photos

class PreviewViewController: UIViewController {
    
    var wholeRect = CGRect.zero
    
    var isInitially = true
    
    let aspectHeight: CGFloat = 1.0
    let aspectWidth: CGFloat = 1.0
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var cropOrigin : CGFloat {
        let width = containerView.frame.width
        let height = width * aspectHeight
        let center = containerView.frame.height / 2
        return center - (height / 2)
    }
    
    weak var delegate: GalleryControllerDelegate?
    
    lazy var containerView = UIView()

    enum Mode {
        case image(image: UIImage)
        case video(video: URL)
        case libraryImage(asset: PHAsset)
        case lbraryVideo(asset: PHAsset)
        
        var shouldShowPreviewButton: Bool {
            switch self {
            case .video: return true
            case .image: return false
            case .libraryImage: return false
            case .lbraryVideo: return true
            }
        }
        
        var shoulShowVideoImageView: Bool {
            return shouldShowPreviewButton
        }
        
        var shouldShowScrollView: Bool {
            return !shoulShowVideoImageView
        }
        
        var shouldShowCropView: Bool {
            return !shoulShowVideoImageView
        }
        
        var galleryMode: GalleryMode {
            switch self {
            case .image, .video: return .cameraSelected
            case .lbraryVideo, .libraryImage: return .photoLibrarySelected
            }
        }
    }
    
    private var mode: Mode?
    
    var cart = Cart()

    @IBOutlet weak var videoImageView: UIImageView?
    private lazy var scrollView = makeScrollView()
    var imageView = UIImageView()
    @IBOutlet weak var buttonPreview: UIButton?
    
    private lazy var topView = makeTopView()
    
    var hollowView: HollowView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonPreview?.setImage(GalleryBundle.image("videoplay"), for: .normal)
        view.addSubview(containerView)
        containerView.backgroundColor = .clear
        containerView.frame = CGRect(x: 0, y: 50, width: view.frame.width, height: view.frame.height - 50)
        
        containerView.addSubview(scrollView)
        scrollView.frame = containerView.bounds
        
        scrollView.decelerationRate = .fast
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        scrollView.addSubview(imageView)
        
        setupViews()
        setupActions()
        
        view.backgroundColor = .clear
        
        updateMode()
        
        hollowView = HollowView(frame: containerView.bounds, transparentRect: CGRect(x: 0, y: cropOrigin, width: containerView.frame.width  , height: containerView.frame.width * aspectHeight ))
        containerView.addSubview(hollowView!)
    }
    
    func updateMode() {
        guard let mode = mode else { return }
        topView.mode = mode.galleryMode
        buttonPreview?.isHidden = !mode.shouldShowPreviewButton
        scrollView.isHidden = !mode.shouldShowScrollView
        videoImageView?.isHidden = !mode.shoulShowVideoImageView
        switch mode {
        case .image(let image):
            updateInitially(with: image)
        case .video(let url):
            url.getimage { (image) in
                self.videoImageView?.image = image
            }
        case .libraryImage(let asset):
            asset.getUIImage { [weak self] (image) in
                guard let img = image else { return }
                self?.updateInitially(with: img)
            }
        case .lbraryVideo(let asset):
            asset.getUIImage { [weak self] (image) in
                self?.videoImageView?.image = image
            }
        }
    }
    
    
    
    func updateInitially(with image: UIImage) {
        let width = containerView.bounds.width
        let height = width * aspectHeight / aspectWidth
        wholeRect = CGRect(x: 0, y: containerView.bounds.height/2-height/2, width: width, height: height)
        imageView.image = image
        imageView.sizeToFit()
        
        let minZoom = max(width / image.size.width, height / image.size.height)
        scrollView.minimumZoomScale = minZoom
        scrollView.zoomScale = minZoom
        scrollView.maximumZoomScale = minZoom*4
        
        guard scrollView.zoomScale == 1.0 else { return }
        
        scrollView.setZoomScale(minZoom, animated: true)
        let desiredOffset = CGPoint(x: 0, y: -scrollView.contentInset.top)
        scrollView.setContentOffset(desiredOffset, animated: false)
    }
    
    
    @IBAction func buttonPreviewTapped(_ sender: Any) {
        guard let mode = mode else { return }
        var player: AVPlayer?
        switch mode {
        case .lbraryVideo(let asset):
            asset.getURL { (url) in
                guard let url = url else { return }
                player = AVPlayer(url: url)
                guard let avplayer = player else { return }
                self.playVideo(player: avplayer)
            }
        case .video(let url):
            player = AVPlayer(url: url)
            guard let avplayer = player else { return }
            self.playVideo(player: avplayer)
        default: break
        }
    }
    
    func playVideo(player: AVPlayer) {
        let playerController = AVPlayerViewController()
        playerController.player = player
        present(playerController, animated: true, completion: nil)
    }
    
    func setupViews() {
        view.addSubview(topView)
        topView.g_pin(on: .left)
        topView.g_pin(on: .right)
        topView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
    }
    
    func setupActions() {
        topView.didTapLeft = { [unowned self] in
            self.dismiss(animated: true, completion: nil)
        }
        
        topView.didTapRight = { [unowned self] in
            self.crop()
        }
    }
    
    func crop() {
        guard let image = imageView.image else { return }
        let scale = 1 / scrollView.zoomScale
        let visibleRect = CGRect(
            x: (scrollView.contentOffset.x + scrollView.contentInset.left) * scale,
            y: (scrollView.contentOffset.y + scrollView.contentInset.top) * scale,
            width: containerView.frame.width * scale,
            height: containerView.frame.width * aspectHeight * scale)
            cart.image = image.crop(rect: visibleRect)
            dismiss(animated: true) {
                EventHub.shared.finishedWithImage?()
            }
    }
}

extension PreviewViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let gapToTheHole = containerView.frame.height/2-wholeRect.height/2
        scrollView.contentInset = UIEdgeInsets(top: gapToTheHole , left: 0, bottom: gapToTheHole , right: 0)
    }
}

private extension PreviewViewController {
    func makeTopView() -> TopView {
        let topView = TopView()
        return topView
    }
    
    func makeScrollView() -> UIScrollView {
        let scrollview = UIScrollView()
        scrollview.backgroundColor = .black
        return scrollview
    }
}

extension PreviewViewController {
    static func show(from: UIViewController, cart: Cart, mode: Mode, delegate: GalleryControllerDelegate) {
        let controller = PreviewViewController()
//        controller.modalTransitionStyle = .crossDissolve
        controller.cart = cart
        controller.mode = mode
        controller.delegate = delegate
//        controller.modalPresentationStyle = .overCurrentContext
        from.present(controller, animated: true, completion: nil)
    }
}
