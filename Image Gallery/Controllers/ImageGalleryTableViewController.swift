//
//  ImageGalleryTableViewController.swift
//  Image Gallery
//
//  Created by Dylan Smith on 4/26/18.
//  Copyright © 2018 Dylan Smith. All rights reserved.
//

import UIKit

class ImageGalleryTableViewController: UITableViewController, UITextFieldDelegate {
    
    // Mark: - Override Lifecyclefunctions
    
    override func viewDidLoad()  {
        super.viewDidLoad()
        //sets the initial collection view based on the top selection and selects this gallery
        self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
        let currentGalleryText = imageGalleryDocuments[0]
        self.performSegue(withIdentifier: "Choose Gallery", sender: currentGalleryText)
    }
    
    //this will allow the user to swipe the table view away and then bring it back to the screen
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if splitViewController?.preferredDisplayMode != .primaryOverlay {
            splitViewController?.preferredDisplayMode = .primaryOverlay
        }
    }
    

    // MARK: - properties
    
    ///The property that maintains the current configuration of the model
    var imageGallery = ImageGallery()
    
    ///The names of all of the image galleries
    private var imageGalleryDocuments : [String] {
        get {
            return imageGallery.galleryNames
        }
    }
    
    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //section 0 has the documents and section 1 has the recently deleted.
        switch section {
            case 0: return imageGalleryDocuments.count - 1
            case 1: return 1
            default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentCell", for: indexPath)
        //sets the text label to the model controller.  The first section is the item documents and the next section is recently deleted documents
        if let tableCell = cell as? GalleryOfImagesTableViewCell {
            if indexPath.section == 0 {
                tableCell.galleryLabelName.text = imageGalleryDocuments[indexPath.row]
                //set up the gesture recognizer, make sure that the object is user interaction enabled.  This tap gesture allows the user to edit the name of the galleries
                let tap = UITapGestureRecognizer(target: self, action: #selector(editLabelName(_:)))
                tap.numberOfTapsRequired = 2
                tableCell.galleryLabelName.addGestureRecognizer(tap)
                tableCell.galleryLabelName.isUserInteractionEnabled = true
            } else {
                tableCell.galleryLabelName.text = imageGalleryDocuments[imageGalleryDocuments.count - 1]
            }
            //hide the initial text field
            tableCell.galleryTextField.isHidden = true
        }
        return cell
    }
    
    // MARK: - Edit Table View Cells
    
    //edit the gallery name using the tap
    @objc func editLabelName(_ recognizer: UITapGestureRecognizer){
        switch recognizer.state {
        case .ended:
            //get the tap location on the string
            let tapLocation = recognizer.location(in: self.tableView)
            //find the tapped cell based on the area
            if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation), let tappedCell = self.tableView.cellForRow(at: tapIndexPath) as? GalleryOfImagesTableViewCell{
                //The tap gesture gets the original text name, allows the user to edit the title and then once the resignation handler is called it changes the model based on the new value.
                let originalGalleryName = tappedCell.galleryLabelName.text!
                tappedCell.editGalleryName()
                tappedCell.resignationHandler = { [weak self, unowned tappedCell] in
                    //input cell is in the closure, which points to its cell, which points back to the closure
                    if let newGalleryName = tappedCell.galleryTextField.text, newGalleryName != originalGalleryName {
                        self?.imageGallery.alterGalleryName(oldName: originalGalleryName, newName: newGalleryName)
                    }
                }
            }
        default: print("pass")
        }
    }
    
    //set this to allow the text field to become the first responder and change the text of the image gallery
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let inputCell = cell as? GalleryOfImagesTableViewCell {
            inputCell.galleryTextField.becomeFirstResponder()
        }
    }
    
    // Mark: - Storyboard Actions
    
    @IBAction func addImageDocument(_ sender: UIBarButtonItem) {
        imageGallery.addNewGallery(named: "Untitled".madeUnique(withRespectTo: imageGalleryDocuments))
        tableView.reloadData()
    }

    // Override to support editing the table view. (Deletion of the rows)
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            if indexPath.section == 0 {
                imageGallery.removeGallery(named: imageGalleryDocuments[indexPath.row])
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        } 
    }
    
    // MARK: - Navigation
    
    //this takes the gallery that has been selected and changes the collection view that is being displayed
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var row: Int
        if indexPath.section == 1 {
           row = imageGalleryDocuments.count - 1
        } else {
            row = indexPath.row
        }
        self.performSegue(withIdentifier: "Choose Gallery", sender: imageGalleryDocuments[row])
        
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //if the table view cell has been selected and the target destination is a Image Gallery Collection (Set up in the storyboard), then change the current gallery name to the selected item and set the model to the instance of the ImageGallery object that we are using.
        if segue.identifier == "Choose Gallery", let nvc = segue.destination as? UINavigationController, let cvc = nvc.visibleViewController as?  ImageGalleryCollectionViewController{
            if let imageGalleryName = (sender as? String) {
                cvc.currentGallery = imageGalleryName
                cvc.imageGalleryModel = imageGallery
            }
        }
    }
}


