import UIKit
import Gallery
import Lightbox
import AVFoundation
import AVKit
import Photos

class ViewController: UIViewController, LightboxControllerDismissalDelegate, GalleryControllerDelegate {
  
  var button: UIButton!
  var gallery: GalleryController!
  let editor: VideoEditing = VideoEditor()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.white
    
    Gallery.Config.VideoEditor.savesEditedVideoToLibrary = true
    //    Gallery.Config.tabsToShow = [.imageTab]
    Gallery.Config.tabsToShow = [.videoTab]
    button = UIButton(type: .system)
    button.frame.size = CGSize(width: 200, height: 50)
    button.setTitle("Open Gallery", for: UIControlState())
    button.addTarget(self, action: #selector(buttonTouched(_:)), for: .touchUpInside)
    
    view.addSubview(button)
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    button.center = CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height/2)
  }
  
  @objc func buttonTouched(_ button: UIButton) {
    gallery = GalleryController()
    gallery.delegate = self
    
    present(gallery, animated: true, completion: nil)
  }
  
  // MARK: - LightboxControllerDismissalDelegate
  
  func lightboxControllerWillDismiss(_ controller: LightboxController) {
    print(controller.images.count)
    let images = controller.images.map {
      $0.orginalImage
    }
    self.gallery.cart.reload(images as! [Image])
  }
  
  // MARK: - GalleryControllerDelegate
  
  func galleryControllerDidCancel(_ controller: GalleryController) {
    controller.dismiss(animated: true, completion: nil)
    gallery = nil
  }
  
  func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
    controller.dismiss(animated: true, completion: nil)
    gallery = nil
    
    
    editor.edit(video: video) { (editedVideo: Video?, tempPath: URL?) in
      DispatchQueue.main.async {
        if let tempPath = tempPath {
          let controller = AVPlayerViewController()
          controller.player = AVPlayer(url: tempPath)
          
          self.present(controller, animated: true, completion: nil)
        }
      }
    }
  }
  
  func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
    //    controller.dismiss(animated: true, completion: nil)
    //    let image:UIImage?
    if images.count > 0 {
      
      if let _ = images[0].uiImage(ofSize: PHImageManagerMaximumSize) {
        controller.dismiss(animated: true, completion: nil)
        gallery = nil
      }else {
        
      }
    }
    
    
  }
  
  func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
    LightboxConfig.DeleteButton.enabled = true
    
    let lightboxImages = images.flatMap {
      ($0.uiImage(ofSize: UIScreen.main.bounds.size),$0)
      }.map({
        LightboxImage(image: ($0.0)!, orginalImage: $0.1)
      })
    
    guard lightboxImages.count == images.count else {
      return
    }
    
    let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
    lightbox.dismissalDelegate = self
    
    controller.present(lightbox, animated: true, completion: nil)
  }
}

