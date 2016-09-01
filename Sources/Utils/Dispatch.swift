import Foundation

struct Dispatch {

  static func on(queue: dispatch_queue_t, block: dispatch_block_t) {
    dispatch_async(queue, block)
  }

  static func main(block: dispatch_block_t) {
    on(dispatch_get_main_queue(), block: block)
  }
}
