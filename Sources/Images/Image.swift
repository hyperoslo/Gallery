import UIKit
import Photos

public enum AssetImageDataStorageLocation {
    case unknown
    case local
    case icloud
}

public class Image: Equatable {
    public let asset: PHAsset
    var _assetImageDataStorageLocation:AssetImageDataStorageLocation = .unknown
    public var assetImageDataStorageLocation:AssetImageDataStorageLocation {
        get {
            if _assetImageDataStorageLocation == .unknown {
                checkHasLocalData()
            }
            return _assetImageDataStorageLocation
        }
        set {
            _assetImageDataStorageLocation = newValue
        }
    }
    // MARK: - Initialization
    
    init(asset: PHAsset) {
        self.asset = asset
    }
    
    func checkHasLocalData() {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        PHImageManager.default().requestImageData(for: asset, options: options) { (imageData, dataUTI, orientation, info) in
            if imageData != nil {
                self.assetImageDataStorageLocation = .local
            }
            else {
                self.assetImageDataStorageLocation = .icloud
            }
        }
    }
}

// MARK: - UIImage

extension Image {
    public func uiImage(ofSize size: CGSize) -> UIImage? {
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.isNetworkAccessAllowed = true
        var result: UIImage? = nil
        
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options) { (image, _) in
            result = image
        }
        
        return result
    }
    public func loadImageFromCloud(ofSize size: CGSize , progressHandle handle:Photos.PHAssetImageProgressHandler?, loadDoneHandle:((UIImage?) -> Swift.Void)?) {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.progressHandler = handle
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options) { (image, _) in
            loadDoneHandle?(image)
        }
    }
    
}

// MARK: - Equatable

public func ==(lhs: Image, rhs: Image) -> Bool {
    return lhs.asset == rhs.asset
}
