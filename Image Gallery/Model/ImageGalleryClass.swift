//
//  ImageGalleryModel.swift
//  Image Gallery
//
//  Created by Dylan Smith on 4/28/18.
//  Copyright © 2018 Dylan Smith. All rights reserved.
//

import Foundation
//This class provides the instance that the app runs off of.  It generages a dictionary with URLs attached and different URLs associated with the specific gallery.

class ImageGallery {
    
    // MARK: - Properties
    
    var imageGalleries =  [String : [URL]]()
    
    var galleryNames = ["Recently Deleted"]
    
    // MARK: - Methods
    
    func addNewImage(to gallery: String, with url: URL, at index: Int) {
        imageGalleries[gallery]?.insert(url, at: index)
    }
    
    func removeImage(from gallery: String, at index: Int) {
        imageGalleries[gallery]?.remove(at: index)
    }
    
    func addNewGallery(named gallery:String) {
        imageGalleries[gallery] = [URL]()
        galleryNames.insert(gallery, at: galleryNames.count - 1)
    }
    
    func alterGalleryName(oldName: String, newName: String) {
        let galleryImageURLS = imageGalleries[oldName]
        imageGalleries.removeValue(forKey: oldName)
        imageGalleries[newName] = galleryImageURLS
        let ix = galleryNames.index(of: oldName) ?? 0
        galleryNames[ix] = newName
    }
    
   func removeGallery(named gallery: String) {
        for galleryURL in imageGalleries[gallery]! {
            //add the deleted image URLs to the deleted gallery.
            let deleted = galleryNames.count - 1
            imageGalleries[galleryNames[deleted]]?.append(galleryURL)
        }
        galleryNames = galleryNames.filter {$0 != gallery }
        imageGalleries.removeValue(forKey: gallery)
    }
    
    // MARK: - Initializers
    
    init() {
        //set up recently deleted model
        imageGalleries[galleryNames[0]] = [URL]()
        //set up other initial values
        for newGallery in ["Chicago Bears", "Chicago Blackhawks", "Chicago Bulls"] {
            self.addNewGallery(named: newGallery)
        }        
    }
}

