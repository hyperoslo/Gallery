import UIKit
import Gallery
import Lightbox

class ViewController: UIViewController, LightboxControllerDismissalDelegate {

  var button: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.whiteColor()

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
    let photos = GalleryController()
    presentViewController(photos, animated: true, completion: nil)
  }

  func showLightbox(images: [UIImage]) {
    let lightbox = LightboxController(images: images.map({ LightboxImage(image: $0) }), startIndex: 0)
    presentViewController(lightbox, animated: true, completion: nil)
  }

  // MARK: - LightboxControllerDismissalDelegate

  func lightboxControllerWillDismiss(controller: LightboxController) {
    
  }
}

