import UIKit
import Gallery
import Lightbox
import AVFoundation
import AVKit

class ViewController: UIViewController, LightboxControllerDismissalDelegate, GalleryControllerDelegate {

  var button: UIButton!
  var gallery: GalleryController!

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.whiteColor()

    Gallery.Config.VideoEditor.savesEditedVideoToLibrary = true

    button = UIButton(type: .System)
    button.frame.size = CGSize(width: 200, height: 50)
    button.setTitle("Open Gallery", forState: .Normal)
    button.addTarget(self, action: #selector(buttonTouched(_:)), forControlEvents: .TouchUpInside)

    view.addSubview(button)
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()

    button.center = CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height/2)
  }

  func buttonTouched(button: UIButton) {
    gallery = GalleryController()
    gallery.delegate = self

    presentViewController(gallery, animated: true, completion: nil)
  }

  // MARK: - LightboxControllerDismissalDelegate

  func lightboxControllerWillDismiss(controller: LightboxController) {
    gallery.reload(controller.images.flatMap({ $0.image }))
  }

  // MARK: - GalleryControllerDelegate

  func galleryControllerDidCancel(controller: GalleryController) {
    controller.dismissViewControllerAnimated(true, completion: nil)
    gallery = nil
  }

  func galleryController(controller: GalleryController, didSelectVideo video: Video) {
    controller.dismissViewControllerAnimated(true, completion: nil)
    gallery = nil

    let editor: VideoEditing = AdvancedVideoEditor()

    editor.edit(video) { (editedVideo: Video?, tempPath: NSURL?) in
      dispatch_async(dispatch_get_main_queue()) {
        print(editedVideo)
        if let tempPath = tempPath {
          let data = NSData(contentsOfURL: tempPath)
          print(data?.length)
          let controller = AVPlayerViewController()
          controller.player = AVPlayer(URL: tempPath)

          self.presentViewController(controller, animated: true, completion: nil)
        }
      }
    }
  }

  func galleryController(controller: GalleryController, didSelectImages images: [UIImage]) {
    controller.dismissViewControllerAnimated(true, completion: nil)
    gallery = nil
  }

  func galleryController(controller: GalleryController, requestLightbox images: [UIImage]) {
    LightboxConfig.DeleteButton.enabled = true

    let lightbox = LightboxController(images: images.map({ LightboxImage(image: $0) }), startIndex: 0)
    lightbox.dismissalDelegate = self

    controller.presentViewController(lightbox, animated: true, completion: nil)
  }
}

