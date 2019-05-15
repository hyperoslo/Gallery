//
//  UIImage-Extensions.swift
//  Gallery-iOS
//
//  Created by Muhammed Azharudheen on 5/6/19.
//  Copyright © 2019 Hyper Interaktiv AS. All rights reserved.
//

import UIKit
extension UIImage {
    
    func crop(rect: CGRect) -> UIImage {
        
        var rectTransform: CGAffineTransform
        switch imageOrientation {
        case .left:
            rectTransform = CGAffineTransform(rotationAngle: radians(90)).translatedBy(x: 0, y: -size.height)
        case .right:
            rectTransform = CGAffineTransform(rotationAngle: radians(-90)).translatedBy(x: -size.width, y: 0)
        case .down:
            rectTransform = CGAffineTransform(rotationAngle: radians(-180)).translatedBy(x: -size.width, y: -size.height)
        default:
            rectTransform = CGAffineTransform.identity
        }
        
        rectTransform = rectTransform.scaledBy(x: scale, y: scale)
        
        if let cropped = cgImage?.cropping(to: rect.applying(rectTransform)) {
            return UIImage(cgImage: cropped, scale: scale, orientation: imageOrientation).fixOrientation()
        } else if let crp = cgImage?.cropping(to: rect) {
            return UIImage(cgImage: crp, scale: scale, orientation: imageOrientation).fixOrientation()
        }
        
        return self
    }
    
    func fixOrientation() -> UIImage {
        if imageOrientation == .up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() ?? self
        UIGraphicsEndImageContext()
        return normalizedImage
    }
    
}
internal func radians(_ degrees: CGFloat) -> CGFloat {
    return degrees / 180 * .pi
}
