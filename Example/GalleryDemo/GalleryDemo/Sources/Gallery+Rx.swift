import Foundation
import UIKit
import Photos
import RxSwift
import Gallery

extension Reactive where Base: PHImageManager {
  private func requestImage(for asset: PHAsset,
                            targetSize: CGSize,
                            contentMode: PHImageContentMode,
                            options: PHImageRequestOptions?) -> Observable<UIImage> {

    return Observable.create { [imageManager = self.base] o in
      let rid = imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: options, resultHandler: { image, _ in
        guard let image = image else {
          o.onError(RxError.unknown)

          return
        }

        o.onNext(image)
        o.onCompleted()
      })

      return Disposables.create { [imageManager] in
        imageManager.cancelImageRequest(rid)
      }
    }
  }

  private func request(image: Image) -> Observable<UIImage> {
    let o = PHImageRequestOptions()
    o.isSynchronous = false
    o.isNetworkAccessAllowed = true
    o.deliveryMode = .highQualityFormat
    o.resizeMode = .fast

    return requestImage(for: image.asset,
                        targetSize: CGSize(width: 1500, height: 1500),
                        contentMode: .aspectFit,
                        options: o)
  }

  func request(images: [Image]) -> Observable<[UIImage]> {
    return Observable.combineLatest(images.map { request(image: $0) })
      .catchErrorJustReturn([])
  }
}
