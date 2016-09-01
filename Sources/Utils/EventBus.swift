import Foundation

class EventBus {

  typealias Action = () -> Void

  static let shared = EventBus()

  // MARK: Initialization

  init() {}

  var close: Action?
  var doneWithImages: Action?
  var doneWithVideos: Action?
  var stackViewTouched: Action?
}
