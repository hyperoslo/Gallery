import UIKit
import Photos

public protocol CartDelegate: class {
  func cart(_ cart: Cart, didAdd image: Image, newlyTaken: Bool)
  func cart(_ cart: Cart, didRemove image: Image)
  func cartDidReload(_ cart: Cart)
}

/// Cart holds selected images and videos information
public class Cart {

  public var images: [Image] = []
  public var video: Video?
  var delegates: NSHashTable<AnyObject> = NSHashTable.weakObjects()

  // MARK: - Initialization

  init() {

  }

  // MARK: - Delegate

  public func add(delegate: CartDelegate) {
    delegates.add(delegate)
  }

  // MARK: - Logic

  public func add(_ image: Image, newlyTaken: Bool = false) {
    guard !images.contains(image) else { return }

    images.append(image)

    for case let delegate as CartDelegate in delegates.allObjects {
      delegate.cart(self, didAdd: image, newlyTaken: newlyTaken)
    }
  }

  public func remove(_ image: Image) {
    guard let index = images.index(of: image) else { return }

    images.remove(at: index)

    for case let delegate as CartDelegate in delegates.allObjects {
      delegate.cart(self, didRemove: image)
    }
  }

  public func reload(_ images: [Image]) {
    self.images = images

    for case let delegate as CartDelegate in delegates.allObjects {
      delegate.cartDidReload(self)
    }
  }

  // MARK: - Reset

  public func reset() {
    video = nil
    images.removeAll()
    delegates.removeAllObjects()
  }
}
