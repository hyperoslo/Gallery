import Foundation

struct Dispatch {

  static func main(block: () -> Void) {
    dispatch_async(dispatch_get_main_queue()) {
      block()
    }
  }
}
