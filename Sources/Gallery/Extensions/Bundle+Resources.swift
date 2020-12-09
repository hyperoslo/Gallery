import Foundation

extension Bundle {
    static var module: Bundle = {
        Bundle(for: GalleryBundle.self)
    }()
}
