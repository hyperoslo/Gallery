import UIKit
import Photos

protocol CartDelegate: class {
  func cart(cart: Cart, didAdd image: Image)
  func cart(cart: Cart, didRemove image: Image)
  func cartDidReload(cart: Cart)
}

class Cart {

  var images: [Image] = []

  // MARK: - Initialization

  init() {

  }

  // MARK: - Logic

  func add(image: Image) {
    images.append(image)
  }

  func remove(image: Image) {
    if let index = images.indexOf(image) {
      images.removeAtIndex(index)
    }
  }

  func reload(images: [Image]) {
    self.images = images
  }
}
