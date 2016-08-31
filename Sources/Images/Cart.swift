import UIKit
import Photos

protocol CartDelegate: class {
  func cart(cart: Cart, didAdd image: Image)
  func cart(cart: Cart, didRemove image: Image)
  func cartDidReload(cart: Cart)
}

class Cart {

  var images: [Image] = []
  var delegates = NSHashTable.weakObjectsHashTable()

  // MARK: - Initialization

  init() {

  }

  // MARK: - Delegate

  func add(delegate: CartDelegate) {
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
}
