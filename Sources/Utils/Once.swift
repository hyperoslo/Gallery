import Foundation

class Once {

  var already: Bool = false

  func run(@noescape block: () -> Void) {
    guard !already else { return }

    block()
    already = true
  }
}
