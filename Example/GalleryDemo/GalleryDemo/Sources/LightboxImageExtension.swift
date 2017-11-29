//
//  LightboxImageExtension.swift
//  Gallery
//
//  Created by linjj on 2017/11/23.
//

import Lightbox
import Gallery
private var keyOfLightboxImageOrginalImage: Void?
public extension LightboxImage {
  var orginalImage: Image? {
    get {
      return objc_getAssociatedObject(self, &keyOfLightboxImageOrginalImage) as? Image
    }
    set(newValue) {
      objc_setAssociatedObject(self, &keyOfLightboxImageOrginalImage, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }
  convenience init(image: UIImage, orginalImage:Image?) {
    self.init(image: image)
    self.orginalImage = orginalImage
  }
}
