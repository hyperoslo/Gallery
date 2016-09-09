import Foundation

struct Dispatch {

  static func on(queue: dispatch_queue_t, block: dispatch_block_t) {
    dispatch_async(queue, block)
  }

  static func main(block: dispatch_block_t) {
    on(dispatch_get_main_queue(), block: block)
  }

  static func background(block: dispatch_block_t) {
    let queue = dispatch_get_global_queue(QOS_CLASS_UTILITY, 0)
    on(queue, block: block)
  }
}
