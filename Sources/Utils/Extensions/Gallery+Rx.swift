//
//  Gallery+Rx.swift
//  Ctzen
//
//  Created by Daniel Marulanda on 2/13/17.
//  Copyright © 2017 Ctzen, Inc. All rights reserved.
//swiftlint:disable force_cast

import Foundation
import RxSwift
import RxCocoa
import Gallery

fileprivate class RxGalleryDelegateProxy: DelegateProxy, DelegateProxyType, GalleryControllerDelegate {

	let imageSubject = PublishSubject<(GalleryController,[UIImage])>()
	let videoSubject = PublishSubject<(GalleryController,Video)>()
	let controllerSubject = PublishSubject<GalleryController>()

	class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
		let gallery:GalleryController = object as! GalleryController
		return gallery.delegate
	}

	class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
		let segmentedControl:GalleryController = object as! GalleryController
		segmentedControl.delegate = delegate as? GalleryControllerDelegate
	}

	func galleryController(_ controller: GalleryController, didSelectImages images: [UIImage]) {
		imageSubject.onNext(controller,images)
		self._forwardToDelegate?.galleryController(controller, didSelectImages: images)
	}

	func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
		videoSubject.onNext(controller, video)
		self._setForward(toDelegate: galleryController(controller, didSelectVideo: video), retainDelegate: false)
	}

	func galleryController(_ controller: GalleryController, requestLightbox images: [UIImage]) {
		imageSubject.onNext(controller, images)
		self._forwardToDelegate?.galleryController(controller, didSelectImages: images)
	}

	func galleryControllerDidCancel(_ controller: GalleryController) {
		controllerSubject.onNext(controller)
		self._forwardToDelegate?.galleryControllerDidCancel(controller)
	}

	deinit {
		imageSubject.onCompleted()
		videoSubject.onCompleted()
		controllerSubject.onCompleted()

	}
}

extension Reactive where Base:GalleryController {

	var selectedImages:Observable<(GalleryController,[UIImage])> {
		let proxy = RxGalleryDelegateProxy.proxyForObject(self.base)
		return proxy.imageSubject
	}

	var selectedVideo:Observable<(GalleryController,Video)> {
		let proxy = RxGalleryDelegateProxy.proxyForObject(self.base)
		return proxy.videoSubject
	}

	var didCancel:Observable<GalleryController> {
		let proxy = RxGalleryDelegateProxy.proxyForObject(self.base)
		return proxy.controllerSubject
	}

}
