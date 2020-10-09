//
//  OrientationMan.swift
//  Gallery-iOS
//
//  Created by chenghao guo on 2020/9/11.
//  Copyright © 2020 Hyper Interaktiv AS. All rights reserved.
//

import AVFoundation
import CoreMotion

class OrientationMan {
    
    let cmmotionManager = CMMotionManager()
    let operationQueue = OperationQueue()
    var currentOrientation = AVCaptureVideoOrientation.portrait
    
    init() {
        operationQueue.maxConcurrentOperationCount = 1
        if cmmotionManager.isDeviceMotionAvailable {
            cmmotionManager.startAccelerometerUpdates(to: operationQueue) {[weak self] (accelerometerData, error) in
                guard let strongSelf = self else {
                    return
                }
                
                if let acceleration = accelerometerData?.acceleration {
                    if acceleration.x >= 0.75 {
                        strongSelf.currentOrientation = .landscapeLeft
                    } else if acceleration.x <= -0.75 {
                        strongSelf.currentOrientation = .landscapeRight
                    } else if acceleration.y <= -0.75 {
                        strongSelf.currentOrientation = .portrait
                    } else if acceleration.y >= 0.75 {
                        strongSelf.currentOrientation = .portraitUpsideDown
                    }
                }
            }
        }
    }
    
    deinit {
        if cmmotionManager.isDeviceMotionAvailable {
            cmmotionManager.stopAccelerometerUpdates()
        }
    }
    
    func videoOrientation() -> AVCaptureVideoOrientation {
        return currentOrientation
    }
}
