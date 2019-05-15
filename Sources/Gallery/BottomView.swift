//
//  BottomView.swift
//  Gallery-iOS
//
//  Created by Muhammed Azharudheen on 4/23/19.
//  Copyright © 2019 Hyper Interaktiv AS. All rights reserved.
//

import UIKit

class BottomView: UIView {
    
    var didTapLeft: (() -> ())?
    var didTapCenter: (() -> ())?
    var didTapRight: (() -> ())?
    
    lazy var leftButton = makeButton()
    lazy var centerButton = makeButton()
    lazy var rightButton = makeButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        
        backgroundColor = .clear
        
        let stackView = UIStackView(arrangedSubviews: [leftButton, centerButton, rightButton])
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        addSubview(stackView)
        
        stackView.g_pin(on: .left, constant: 16)
        stackView.g_pin(on: .right, constant: -16)
        stackView.g_pin(on: .bottom)
        stackView.g_pin(on: .top)
        
        leftButton.setTitle("gallery.bottom.library".g_localize(fallback: "lib"), for: .normal)
        centerButton.setTitle("gallery.bottom.photo".g_localize(fallback: "pht"), for: .normal)
        rightButton.setTitle("gallery.bottom.video".g_localize(fallback: "vid"), for: .normal)
        
        leftButton.tag = 0
        centerButton.tag = 1
        rightButton.tag = 2
        
        rightButton.isUserInteractionEnabled = false
        
        [leftButton, centerButton, rightButton].forEach {
            $0.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
        }
        
        let seperatorView = UIView()
        seperatorView.backgroundColor = .bottomSeperatorColor
        addSubview(seperatorView)
        seperatorView.g_pin(on: .left)
        seperatorView.g_pin(on: .top)
        seperatorView.g_pin(on: .right)
        seperatorView.g_pin(height: 1)
    }
    
    @objc
    private func buttonTapped(_ sender: UIButton) {
        
        [leftButton, centerButton, rightButton].forEach({ $0.isSelected = (sender.tag == $0.tag) })
        
        switch sender.tag {
        case 0: didTapLeft?()
        case 1: didTapCenter?()
        case 2: didTapRight?()
        default: break
        }
    }
    
    private func makeButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white.withAlphaComponent(0.4), for: .normal)
        button.setTitleColor(UIColor.white, for: .selected)
        if let font = GalleryConfig.shared.bottomFont {
            button.titleLabel?.font = font
        }
        return button
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}

