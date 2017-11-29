//
//  MaskProgressView.swift
//  maskTest
//
//  Created by linjj on 2017/11/23.
//  Copyright © 2017年 linjj. All rights reserved.
//

import UIKit

class MaskProgressView: UIView {
    public var progress:Float = 0.0 {
        didSet{
            self.layoutSubviews()
        }
    }
    public var maskImage:UIImage?
    public var hightLightColor:UIColor = UIColor(red: 61/255, green: 172/255, blue: 247/255, alpha: 1){
        didSet{
            self.backgroundView.backgroundColor = hightLightColor
        }
    }
    
    public var normalColor = UIColor.lightGray {
        didSet{
            self.backgroundColor = normalColor
        }
    }
    var backgroundView = UIView()
    var maskLayer = CALayer()
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    init(withMaskImage maskImage:UIImage) {
        super.init(frame: CGRect.zero)
        self.maskImage = maskImage
        self.backgroundView.backgroundColor = hightLightColor
        self.addSubview(self.backgroundView)
        self.maskLayer.contents = self.maskImage?.cgImage
        self.layer.mask = self.maskLayer
        self.backgroundColor = normalColor
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height * CGFloat(progress))
        self.maskLayer.frame = self.frame
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        fatalError("init(coder:) has not been implemented")
    }
}
