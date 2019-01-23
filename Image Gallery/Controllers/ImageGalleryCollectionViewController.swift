//
//  ImageGalleryCollectionViewController.swift
//  Image Gallery
//
//  Created by Dylan Smith on 4/5/18.
//  Copyright © 2018 Dylan Smith. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Image"

class ImageGalleryCollectionViewController: UICollectionViewController  {
    
    // MARK: - ViewController Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = currentGallery
    }
    
    // MARK: - Properties
    
    var imageGalleryModel : ImageGallery?
    var currentGallery : String?
    
    //This variable returns the URLs associated with the gallery.
    private var imageURLSUsedInCollectionView: [URL]? {
        get {
            return imageGalleryModel?.imageGalleries[(currentGallery)!] ?? [URL]()
        }
    }
    
    //these variables will be used for the sizing variables.  They get called in the extension that lay's out the variables
    private let itemsPerRow: CGFloat = 4
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)

    var imageURL: URL? {
        return self.imageURL?.imageURL
    }
    
    // MARK: - Outlets
    
    @IBOutlet var imageCollectionView: UICollectionView! {
        didSet {
            imageCollectionView.dataSource = self
            imageCollectionView.delegate = self
            imageCollectionView.dragDelegate = self
            imageCollectionView.dropDelegate = self
        }
    }
    
    // Mark: - Navigation Methods
    
    /*ensure that the selected item is a Image Gallery Cell and that there is an image in the cell, then call the Choose image segue to the scroll view. Commented it out as the segue is defined in the storyboard
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            //ALWAYS ENSURE THAT THE SENDER IS SELF
            //self.performSegue(withIdentifier: "Choose Image", sender: self)
    }*/
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation.  This sends the image over to the scroll view
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Choose Image", let cvc = segue.destination as? ImageViewController {
            //Since the segue is attached to the cell, can just get the image from the object that is sending the action
                if let selectedImage = (sender as? ImageGalleryCollectionViewCell)?.imageView?.image{
                    cvc.imageToSet = selectedImage
                }
            }
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        //we will only have one section per collection view
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLSUsedInCollectionView?.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        cell.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        if let imageCell = cell as? ImageGalleryCollectionViewCell {
            imageCell.fetch(for: imageURLSUsedInCollectionView![indexPath.item])
        }
        return cell
    }

}

// MARK: - UICollectionVIewDelegateFLowLayout

extension ImageGalleryCollectionViewController : UICollectionViewDelegateFlowLayout {
    // this function gets the size of each cell based on how many items you want per row.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth/itemsPerRow
        //makes square view sizes
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    //sets the insets for each cell per section
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    //returns the spacing for each line
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
}

// MARK: - UICollectionViewDragDelegate

extension ImageGalleryCollectionViewController: UICollectionViewDragDelegate {
    //this allows you to drag items from the collection view
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItems(at: indexPath)
    }
    //this is for adding items to the collection view
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        //cast the new image (at the specified index path) as a image collection view cell as an image view.  Make it into a UI drag item as the image and return it to the dragItem array.
        if let  attributedURL = (imageCollectionView.cellForItem(at: indexPath) as? ImageGalleryCollectionViewCell)?.associatedImageURL?.absoluteURL {
            let dragItem = UIDragItem(itemProvider:  NSItemProvider(contentsOf: attributedURL)!)
            dragItem.localObject = attributedURL
            return [dragItem]
        } else {
            return []
        }
    }
}

// MARK: - UICollectionViewDropDelegate

extension ImageGalleryCollectionViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator){
        let destinationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                //make sure that the object that we are dragging is a image.  This is for the local objects
                if let localImageURL = (item.dragItem.localObject as? NSURL)?.absoluteURL {
                    collectionView.performBatchUpdates({
                        imageGalleryModel?.removeImage(from: currentGallery!, at: sourceIndexPath.item)
                        imageGalleryModel?.addNewImage(to: currentGallery!, with: localImageURL, at: destinationIndexPath.item)
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destinationIndexPath])
                        })
                }
            } else {
                //uses the drop placeholder for external objects and deques the next item
                let placeholderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destinationIndexPath, reuseIdentifier: "DropPlaceholder"))
                //if the object provided is an image URL, dispatch off the main queue to get the image and add the image url to the correct path.
                item.dragItem.itemProvider.loadObject(ofClass: NSURL.self) { (provider, error) in
                    DispatchQueue.main.async {
                        if let url = (provider as? URL)?.imageURL {
                            //Get the image and store the data in an array before you load it into the collection view.
                            placeholderContext.commitInsertion(dataSourceUpdates: { insertionIndexPath in
                                self.imageGalleryModel?.addNewImage(to: self.currentGallery! , with: url.imageURL, at: insertionIndexPath.item)
                            })
                        } else {
                            placeholderContext.deletePlaceholder()
                        }
                    }
                }
            }
        }
    }
    
    //this drop interaction ensures that the only objects that are accepted are ones that have a URL and an image.  If it is an internal drag it ensures that there is only a UIImage being moved, if it is external it looks for the Image and URL
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return isSelf ? session.canLoadObjects(ofClass: UIImage.self) : session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
    }
    
    //dropSession instead of just sessionDidUpdate.  This was the key
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        //check to ensure that the session is a local drag session (it is a collection view), if it is we move the object, if not we copy it.
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move: .copy, intent: .insertAtDestinationIndexPath)
    }
}

/*
 Notes:
 1. If you define a segue programatically then you dont need to define one on the storyboard and visa versa.  Regardless of where it is called be sure to prepare for the segue
 2.  Set the Navigation controller above the layer of where the object is to ensure the stack is set up correctly.  Use a "Show" segue to ensure the back button is still there.
 3. When calling a segue programtically.  Always be sure to define the sender as self.  
 
 */
