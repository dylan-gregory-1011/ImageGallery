//
//  ImageGalleryCollectionViewCell.swift
//  Image Gallery
//
//  Created by Dylan Smith on 4/5/18.
//  Copyright © 2018 Dylan Smith. All rights reserved.
//

import UIKit

class ImageGalleryCollectionViewCell: UICollectionViewCell {
    
    // Mark: - Storyboard Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // Mark: - Properties
    
    var associatedImageURL: URL?
    
    // Mark: Public Functions
    
    ///This function fetches the image from the url and once it returns a bag of data (Fetched off the main queue), it returns to the main queue, stops and hides the spinner and sets the image and url of the Collection view cell.
    func fetch(for url: URL) {
        spinner.startAnimating()
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let urlContents = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    if let imageData = urlContents {
                        // Get rid of the spinner, stop animating and set the cell to the image
                        self?.spinner.stopAnimating()
                        self?.spinner.alpha = 0.0
                        //set the cell to the image and save the url
                        self?.imageView.image = UIImage(data: imageData)
                        self?.associatedImageURL = url
                }
            }
        }
    }
}
