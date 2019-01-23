//
//  ImageViewController.swift
//  Image Gallery
//
//  Created by Dylan Smith on 5/17/18.
//  Copyright © 2018 Dylan Smith. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK: - ViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = imageToSet
        imageView.sizeToFit()
        scrollView?.contentSize = imageView.frame.size
    }
    
    // MARK: - Properties
    
    private var imageView =  UIImageView()
    var imageToSet: UIImage?
    
    // MARK: - Methods
 
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    // MARK: - Outlets
    
    //initializes the scroll view and allows for scaling of the image.
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            scrollView.maximumZoomScale = 1.0
            scrollView.minimumZoomScale = 1/25
            scrollView.addSubview(imageView)
        }
    }
}

