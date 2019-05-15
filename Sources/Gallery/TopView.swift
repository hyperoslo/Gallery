//
//  TopView.swift
//  Gallery-iOS
//
//  Created by Muhammed Azharudheen on 4/23/19.
//  Copyright © 2019 Hyper Interaktiv AS. All rights reserved.
//

import UIKit

class TopView: UIView {
    
    var padding: CGFloat = 8
    
    var didTapLeft: (() -> ())?
    var didTapRight: (() -> ())?
    
    var mode: GalleryMode = .cameraUnselected {
        didSet {
            updateTopView()
        }
    }
    
    var leftTitle: String? {
        didSet {
            buttonLeft.setTitle(leftTitle, for: .normal)
        }
    }
    
    var title: String? {
        didSet {
            labelTitle.text = title
        }
    }
    
    var rightTitle: String? {
        didSet {
            buttonRight.setTitle(rightTitle, for: .normal)
        }
    }
    
    lazy var buttonLeft = makeButtonLeft()
    lazy var labelTitle = makeLabelTitle()
    lazy var buttonRight = makeButtonRight()
    
    private func makeButtonLeft() -> UIButton {
        let button = UIButton()
        button.setTitleColor(UIColor.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        if let font = GalleryConfig.shared.topCloseFont {
            button.titleLabel?.font = font
        }
        if let color = GalleryConfig.shared.buttonLeftColor {
            button.setTitleColor(color, for: .normal)
        }
        return button
    }
    
    private func makeLabelTitle() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.white
        if let font = GalleryConfig.shared.topTitleFont {
            label.font = font
        }
        if let color = GalleryConfig.shared.titleColor {
            label.textColor = color
        }
        return label
    }
    
    private func makeButtonRight() -> UIButton {
        let button = UIButton()
        button.setTitleColor(UIColor.white, for: .normal)
        if let font = GalleryConfig.shared.topSaveFont {
            button.titleLabel?.font = font
        }
        if let color = GalleryConfig.shared.buttonRightColor {
            button.setTitleColor(color, for: .normal)
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 52).isActive = true
        
        backgroundColor = UIColor.black
        
        setup()
        updateTopView()
    }
    
    private func setup() {
        addSubview(buttonLeft)
        
        backgroundColor = GalleryConfig.shared.topviewBackgroundColor ?? .black
        
        NSLayoutConstraint.activate([
            buttonLeft.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            buttonLeft.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
        
        addSubview(labelTitle)
        NSLayoutConstraint.activate([
            labelTitle.centerYAnchor.constraint(equalTo: centerYAnchor),
            labelTitle.centerXAnchor.constraint(equalTo: centerXAnchor)
            ])
        
        addSubview(buttonRight)
        NSLayoutConstraint.activate([
            buttonRight.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            buttonRight.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
        
        buttonLeft.addTarget(self, action: #selector(buttonLeftTapped), for: .touchUpInside)
        buttonRight.addTarget(self, action: #selector(buttonRightTapped), for: .touchUpInside)
    }
    
    private func updateTopView() {
        buttonLeft.setTitle(mode.leftTitle, for: .normal)
        buttonRight.setTitle(mode.rightTitle, for: .normal)
        buttonRight.isHidden = mode.shouldHideButtonRight
        labelTitle.text = mode.title
    }
    
    @objc private func buttonLeftTapped() {
        didTapLeft?()
    }
    
    @objc private func buttonRightTapped() {
        didTapRight?()
    }
}

enum GalleryMode {
    
    case photoLibraryUnselected
    case photoLibrarySelected
    case cameraUnselected
    case cameraSelected
    
    var leftTitle: String {
        switch self {
        case .photoLibraryUnselected, .cameraUnselected, .photoLibrarySelected:
            return "gallery.top.close".g_localize(fallback: "close")
        case .cameraSelected:
            return "gallery.top.retake".g_localize(fallback: "retake")
        }
    }
    
    var rightTitle: String {
        return "gallery.top.save".g_localize(fallback: "save")
    }
    
    var shouldHideButtonRight: Bool {
        switch self {
        case .cameraUnselected, .photoLibraryUnselected: return true
        case .photoLibrarySelected, .cameraSelected: return false
        }
    }
    
    var title: String {
        return "gallery.top.addmedia".g_localize(fallback: "add_media")
    }
    
    var shouldShowPreviewScreen: Bool {
        switch self {
        case .cameraSelected: return true
        case .photoLibrarySelected, .photoLibraryUnselected, .cameraUnselected: return false
        }
    }
}

public struct GalleryConfig {
    
    public static var shared = GalleryConfig()
    
    private init() { }
    
    // Top View
    
    // colors
    
    public var topviewBackgroundColor: UIColor?
    
    public var buttonLeftColor: UIColor?
    
    public var titleColor: UIColor?
    
    public var buttonRightColor: UIColor?
    
    
    
    public var topCloseFont: UIFont?
    
    public var topTitleFont: UIFont?
    
    public var topSaveFont: UIFont?
    
    public var bottomSelectedFont: UIFont?
    
    public var bottomUnselectedFont: UIFont?
    
    
    // Bottom View
    public var bottomFont: UIFont?
    
    
    // photos controller
    
    public var selectedAlbumFont: UIFont?
    public var albumTitleFont: UIFont?
    public var albumCountFont: UIFont?
    
    public var selectedAlbumColor: UIColor?
    public var albumTitleColor: UIColor?
    public var albumCountColor: UIColor?
    
    
    public var cropMode: CropMode = .square
}

public enum CropMode {
    case square
    case rectangle
}
