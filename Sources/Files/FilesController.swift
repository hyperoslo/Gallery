//
//  FilesController.swift
//  Gallery-iOS
//
//  Created by Johan Sverin on 2018-01-04.
//  Copyright © 2018 Hyper Interaktiv AS. All rights reserved.
//

import UIKit

class FilesController: UIDocumentPickerViewController, UIDocumentPickerDelegate {
    
    let cart: Cart
    
    public init(cart: Cart) {
        self.cart = cart
        super.init(documentTypes: ["public.image"], in: .import)
        if #available(iOS 11.0, *) {
            self.allowsMultipleSelection = true
        }
        cart.delegates.add(self)
        self.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        for url in urls {
            cart.add(url)
        }
        EventHub.shared.doneWithFiles?()
    }
    
}
