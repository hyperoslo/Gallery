import UIKit
import Photos
public enum AssetVideoDataStorageLocation {
    case unknown
    case local
    case icloud
}
public class Video: Equatable {
    
    public let asset: PHAsset
    var _assetVideoDataStorageLocation:AssetVideoDataStorageLocation = .unknown
    public var assetVideoDataStorageLocation:AssetVideoDataStorageLocation {
        get {
            return _assetVideoDataStorageLocation
        }
        set {
            _assetVideoDataStorageLocation = newValue
        }
    }
    var durationRequestID: Int = 0
    var duration: Double = 0
    
    // MARK: - Initialization
    
    init(asset: PHAsset) {
        self.asset = asset
    }
    
    func getAssetVideoDataStorageLocation(handle :@escaping (AssetVideoDataStorageLocation) -> Swift.Void)
    {
        if _assetVideoDataStorageLocation == .unknown {
            checkHasLocalData(handle: handle)
        }
        else {
            handle(_assetVideoDataStorageLocation)
        }
    }
    
    func fetchDuration(_ completion: @escaping (Double) -> Void) {
        guard duration == 0
            else {
                completion(duration)
                return
        }
        
        if durationRequestID != 0 {
            PHImageManager.default().cancelImageRequest(PHImageRequestID(durationRequestID))
        }
        let requestOptions = PHVideoRequestOptions()
       
        let id = PHImageManager.default().requestAVAsset(forVideo: asset, options: requestOptions) {
            asset, mix, _ in
            
            self.duration = asset?.duration.seconds ?? 0
            completion(self.duration)
        }
        
        durationRequestID = Int(id)
    }
    
    public func fetchPlayerItem(_ completion: @escaping (AVPlayerItem?) -> Void) {
        PHImageManager.default().requestPlayerItem(forVideo: asset, options: nil) {
            item, _ in
            
            completion(item)
        }
    }
    
    public func fetchAVAsset(_ completion: @escaping (AVAsset?) -> Void){
        PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) { avAsset, _, _ in
            completion(avAsset)
        }
    }
    
    public func fetchThumbnail(_ size: CGSize = CGSize(width: 100, height: 100), completion: @escaping (UIImage?) -> Void) {
        PHImageManager.default().requestImage(for: asset, targetSize: size,
                                              contentMode: .aspectFill, options: nil)
        { image, _ in
            completion(image)
        }
    }
    func checkHasLocalData(handle :@escaping (AssetVideoDataStorageLocation) -> Swift.Void) {
        let options = PHVideoRequestOptions()
        
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { (asset, mix, _) in
            if asset != nil {
                self.assetVideoDataStorageLocation = .local
            }
            else {
                self.assetVideoDataStorageLocation = .icloud
            }
            DispatchQueue.main.async {
                handle(self.assetVideoDataStorageLocation)
            }
           
        }
    }
}

extension Video {
    public func getUrlAndThumbnail(size: CGSize = CGSize(width: 100, height: 100), completionHandler : @escaping ((_ videoURL : URL?, _ videoThumbnail : UIImage?) -> Swift.Void)) {
        loadAssetFromCloud(progressHandle: nil) {[weak self] (asset) in
            if let urlAsset = asset as? AVURLAsset {
                let localVideoUrl: URL = urlAsset.url as URL
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                options.isNetworkAccessAllowed = true
                PHImageManager.default().requestImage(for: (self?.asset)!, targetSize: size,
                                                      contentMode: .aspectFill, options: options){ image, _ in
                                                        DispatchQueue.main.async {
                                                            completionHandler(localVideoUrl,image)
                                                        }
                    
                }
                
            } else {
                DispatchQueue.main.async {
                    completionHandler(nil,nil)
                }
            }
        }
    }
    public func loadAssetFromCloud(progressHandle handle:Photos.PHAssetImageProgressHandler?, loadDoneHandle:((AVAsset?) -> Swift.Void)?) {
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        options.progressHandler = handle
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { (asset, mix, _) in
            loadDoneHandle?(asset)
        }
    }
}

// MARK: - Equatable

public func ==(lhs: Video, rhs: Video) -> Bool {
    return lhs.asset == rhs.asset
}
