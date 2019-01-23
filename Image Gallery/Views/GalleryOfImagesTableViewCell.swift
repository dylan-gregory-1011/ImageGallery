//
//  GalleryOfImagesTableViewCell.swift
//  Image Gallery
//
//  Created by Dylan Smith on 5/12/18.
//  Copyright © 2018 Dylan Smith. All rights reserved.
//

import UIKit

class GalleryOfImagesTableViewCell: UITableViewCell, UITextFieldDelegate {
    
    // Mark: - Storyboard Outlets

    @IBOutlet weak var galleryLabelName: UILabel!
    @IBOutlet weak var galleryTextField: UITextField! {
        didSet {
            //need to ensure that the delegate is itself so that it can resign the first responder
            galleryTextField.delegate = self
        }
    }
    
    //Mark: - Public Functions
        
    func editGalleryName() {
        galleryLabelName.isHidden = true
        galleryTextField.isHidden = false
        galleryTextField.text = galleryLabelName.text
    }
    
    // MARK: - TextField Delegation
    
    // this resignation handler is empty so that it can be called in the view controller
    var resignationHandler: (() -> Void)?
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        resignationHandler?()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        galleryTextField.resignFirstResponder()
        galleryTextField.isHidden = true
        galleryLabelName.isHidden = false
        galleryLabelName.text = galleryTextField.text
        return true
    }
}
