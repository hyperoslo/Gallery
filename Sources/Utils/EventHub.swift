import Foundation

class EventHub {
    
    typealias Action = () -> Void
    
    static let shared = EventHub()
    
    // MARK: Initialization
    
    init() {}
    
    var close: Action?
    var doneWithImages: Action?
    var doneWithVideos: Action?
    var stackViewTouched: Action?
    var capturedImage: Action?
    var capturedVideo: Action?
    
    var dismissPreview: Action?
    
    var finishedWithImage: Action?
    
}
