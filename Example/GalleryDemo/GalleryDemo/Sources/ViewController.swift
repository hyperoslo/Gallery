import UIKit
import Gallery

class ViewController: UIViewController {

  var button: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.whiteColor()

    button = UIButton(type: .System)
    button.frame.size = CGSize(width: 200, height: 50)
    button.setTitle("Open Photos", forState: .Normal)
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
}

