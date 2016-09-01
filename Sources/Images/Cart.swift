import UIKit
import Photos

protocol CartDelegate: class {
  func cart(cart: Cart, didAdd image: Image)
  func cart(cart: Cart, didRemove image: Image)
  func cartDidReload(cart: Cart)
}

class Cart {

  static let shared = Cart()

  var images: [Image] = []
  private var lightBoxUIImages: [UIImage] = []
  var video: Video?
  var delegates = NSHashTable.weakObjectsHashTable()

  // MARK: - Initialization

  private init() {

  }

  // MARK: - Delegate

  func add(delegate delegate: CartDelegate) {
    delegates.addObject(delegate)
  }

  // MARK: - Logic

  func add(image: Image) {
    images.append(image)

    for case let delegate as CartDelegate in delegates.allObjects {
      delegate.cart(self, didAdd: image)
    }
  }

  func remove(image: Image) {
    guard let index = images.indexOf(image) else { return }

    images.removeAtIndex(index)

    for case let delegate as CartDelegate in delegates.allObjects {
      delegate.cart(self, didRemove: image)
    }
  }

  func reload(images: [Image]) {
    self.images = images

    for case let delegate as CartDelegate in delegates.allObjects {
      delegate.cartDidReload(self)
    }
  }

  // MARK: - Reset

  func reset() {
    video = nil
    images.removeAll()
    delegates.removeAllObjects()
  }

  // MARK: - UIImages

  func UIImages() -> [UIImage] {
    lightBoxUIImages = Fetcher.fetchImages(images.map({ $0.asset }))
    return lightBoxUIImages
  }

  func reload(UIImages: [UIImage]) {
    var changedImages: [Image] = []

    lightBoxUIImages.filter {
      return UIImages.contains($0)
    }.flatMap {
      return lightBoxUIImages.indexOf($0)
    }.forEach { index in
      if index < images.count {
        changedImages.append(images[index])
      }
    }

    lightBoxUIImages = []
    reload(changedImages)
  }
}
