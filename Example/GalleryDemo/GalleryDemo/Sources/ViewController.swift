import UIKit
import Gallery
import Lightbox
import AVFoundation
import AVKit
import Photos
import RxSwift

class ViewController: UIViewController, LightboxControllerDismissalDelegate, GalleryControllerDelegate {
  private var disposeBag: DisposeBag? = nil

  var button: UIButton!
  var gallery: GalleryController?
  let editor: VideoEditing = VideoEditor()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.white

    Gallery.Config.VideoEditor.savesEditedVideoToLibrary = true

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

  func buttonTouched(_ button: UIButton) {
    let gallery = GalleryController()
    gallery.delegate = self

    present(gallery, animated: true, completion: nil)

    self.gallery = gallery
  }

  // MARK: - LightboxControllerDismissalDelegate

  func lightboxControllerWillDismiss(_ controller: LightboxController) {

  }

  // MARK: - GalleryControllerDelegate

  func galleryControllerDidCancel(_ controller: GalleryController) {
    controller.dismiss(animated: true, completion: nil)
    gallery = nil
    disposeBag = nil
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
    let disposeBag = DisposeBag()

    PHImageManager.default().rx.request(images: images)
      .observeOn(MainScheduler.instance)
      .do(
        onCompleted: { [controller] in
          controller.loading = false
        },
        onSubscribe: { [controller] in
          controller.loading = true
        }
      )
      .subscribe(onNext: { [controller, weak self] uiImages in
        guard let strongSelf = self, !controller.isBeingDismissed else { return }

        strongSelf.gallery = nil
        
        controller.dismiss(animated: true, completion: { [strongSelf] in
          let lightbox = LightboxController(images: uiImages.map({ LightboxImage(image: $0) }), startIndex: 0)
          lightbox.dismissalDelegate = strongSelf

          strongSelf.present(lightbox, animated: true, completion: nil)
        })
      })
      .disposed(by: disposeBag)

    self.disposeBag = disposeBag
  }

  func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
    let lightboxImages = images.flatMap { $0.uiImage(ofSize: UIScreen.main.bounds.size) }.map({ LightboxImage(image: $0) })

    guard !lightboxImages.isEmpty else {
      return
    }

    let lightbox = LightboxController(images: lightboxImages, startIndex: 0)
    lightbox.dismissalDelegate = self

    controller.present(lightbox, animated: true, completion: nil)
  }
}

