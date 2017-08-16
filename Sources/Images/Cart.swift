import UIKit
import Photos

protocol CartDelegate: class {
  func cart(_ cart: Cart, didAdd image: Image, newlyTaken: Bool)
  func cart(_ cart: Cart, didRemove image: Image)
  func cartDidReload(_ cart: Cart)
}

public class Cart {

  public var images: [Image] = []
  public var video: Video?
  var delegates: NSHashTable<AnyObject> = NSHashTable.weakObjects()

  // MARK: - Initialization

  init() {

  }

  // MARK: - Delegate

  func add(delegate: CartDelegate) {
    delegates.add(delegate)
  }

  // MARK: - Logic

  func add(_ image: Image, newlyTaken: Bool = false) {
    guard !images.contains(image) else { return }

    images.append(image)

    for case let delegate as CartDelegate in delegates.allObjects {
      delegate.cart(self, didAdd: image, newlyTaken: newlyTaken)
    }
  }

  func remove(_ image: Image) {
    guard let index = images.index(of: image) else { return }

    images.remove(at: index)

    for case let delegate as CartDelegate in delegates.allObjects {
      delegate.cart(self, didRemove: image)
    }
  }

  func reload(_ images: [Image]) {
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
}
