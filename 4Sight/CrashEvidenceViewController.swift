//
//  CrashEvidenceViewController.swift
//  4Sight
//
//  Created by Simon Withington on 01/06/2016.
//  Copyright © 2016 Appitized. All rights reserved.
//

import UIKit

struct EvidenceMode {
    let caption: String
    let prompt: String
    let image: UIImage
}

class CrashEvidenceViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate {

    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let minSpacing: CGFloat = 10
    let imagePicker = UIImagePickerController()
    
    let evidenceModes: [EvidenceMode] = [
        EvidenceMode(caption: "Your Vehicle",   prompt: "Please submit accident photos of your vehicle",    image: UIImage(named: "icon_crash")!),
        EvidenceMode(caption: "Other Vehicle",  prompt: "Please submit accident photos of other vehicle",   image: UIImage(named: "icon_crash_other")!),
        EvidenceMode(caption: "Road Condition", prompt: "Please submit accident photos of the road",        image: UIImage(named: "icon_road")!)
    ]
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    var evidence: [[UIImage]] = [[], [], []]
    var currentEvidenceIndex = 0 {
        didSet {
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        
        confirmButton.layer.cornerRadius = 10
        confirmButton.layer.masksToBounds = true
        confirmButton.layer.borderColor = UIColor.white.cgColor
        confirmButton.layer.borderWidth = 3
    }
    
    func updateUI() {
        collectionView.reloadData()
        self.promptLabel.text = evidenceModes[currentEvidenceIndex].prompt
        self.imageView.image = evidenceModes[currentEvidenceIndex].image
        self.captionLabel.text = evidenceModes[currentEvidenceIndex].caption
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            evidence[currentEvidenceIndex].append(image)
            updateUI()
        }
        
        let newOffsetX = collectionView.contentOffset.x + minSpacing + collectionView.frame.size.height
        
        dismiss(animated: true, completion: {
            self.collectionView.setContentOffset(CGPoint(x: newOffsetX, y: 0), animated: true)
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: IBActions
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        if currentEvidenceIndex > 0 {
            currentEvidenceIndex -= 1
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func submitButtonPressed(_ sender: AnyObject) {
        
        if currentEvidenceIndex >= evidence.count-1 {
            
            if evidence.flatMap({$0}).count == 0 {
                performSegue(withIdentifier: "showWitnessDetails", sender: self)
                return
            }
            
            let group = DispatchGroup()
            LoadingIndicator.show(targetView: view)
            
            for i in 0...evidence.count-1 {
                
                let type = ["owner", "other", "road"][i]
                
                let images = evidence[i]
                
                if images.count == 0 {
                    continue
                }
                
                for j in 0...images.count-1 {

                    let imageData = compressImageData(imageData: UIImageJPEGRepresentation(images[j], 1.0)!) //{//UIImagePNGRepresentation(images[j]) {
                            
                    group.enter()
                
                    MediaService.uploadImage(imageData: imageData, type: type, index: j, completion: {
                        (error) in
                        
                        if let error = error {
                            
                            debugPrint(error) // TODO: Handle this better if we have no network access?
                            
                            let confirmationAlert = UIAlertController(title: "Error", message: "\(error.userInfo["message"] as! String?) The photo has been saved to your camera roll.", preferredStyle: .alert)
                            
                            if error.userInfo["message"] == nil {
                                confirmationAlert.message = "\(error.userInfo["NSLocalizedDescription"] as! String?) The photo has been saved to your camera roll."
                            }
                            
                            confirmationAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                            self.present(confirmationAlert, animated: true, completion: nil)
                            
                            if let compressedJPGImage = UIImage(data: imageData) {
                                UIImageWriteToSavedPhotosAlbum(compressedJPGImage, nil, nil, nil)
                            }
                        }
                        
                        group.leave()
                    })
                }
//          }
        }
            
            group.notify(queue: DispatchQueue.main) {
                [weak self] in
                
                LoadingIndicator.hide()
                
                if let weakSelf = self {
                    weakSelf.performSegue(withIdentifier: "showWitnessDetails", sender: weakSelf)
                }
            }
            
        } else {
            currentEvidenceIndex += 1
        }
    }
    
    func compressImageData(imageData: Data) -> Data {
        
        let imageToCompress:UIImage! = UIImage(data:imageData, scale:1.0)
        let imageHeight = imageToCompress.size.height
        let imageWidth = imageToCompress.size.width
        let maxLength: CGFloat = 1000
        var scale: CGFloat = 0
        
        if(imageWidth > imageHeight) {
            
            scale = maxLength / imageWidth
            
        }else{
            
            scale = maxLength / imageHeight
        }
        
        
        return UIImageJPEGRepresentation(imageToCompress.resizeWith(percentage: scale)!, 0.8)!
    }
 
    // MARK: CollectionView
 
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if evidence[currentEvidenceIndex].count >= 5 {  // 2016-10-5 by Alex
            return 5
        }
        else {
            return evidence[currentEvidenceIndex].count + 1
        }
    }
 
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EvidenceCollectionViewCell.reuseIdentifier(), for: indexPath) as! EvidenceCollectionViewCell
        
        if (indexPath as NSIndexPath).row >= evidence[currentEvidenceIndex].count {
            cell.imageView.contentMode = .center
            cell.imageView.image = UIImage(named: "icon_plus")
        } else {
            cell.imageView.contentMode = .scaleAspectFill
            cell.imageView.image = evidence[currentEvidenceIndex][(indexPath as NSIndexPath).row]
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if (indexPath as NSIndexPath).row >= evidence[currentEvidenceIndex].count {
            
            present(imagePicker, animated: true, completion: nil)
        } else { // 2016-10-5 by Alex
            //Create the AlertController
            let actionSheetController: UIAlertController = UIAlertController(title: "Action Sheet", message: nil, preferredStyle: .actionSheet)
            
            //Create and add the Cancel action
            let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
                //Just dismiss the action sheet
            }
            actionSheetController.addAction(cancelAction)
            //Create and add first option action
            let removePictureAction: UIAlertAction = UIAlertAction(title: "Remove Picture", style: .default) { action -> Void in
                collectionView .performBatchUpdates({
                    print(indexPath.row)
                    self.evidence[self.currentEvidenceIndex].remove(at: indexPath.row)
                    if self.evidence[self.currentEvidenceIndex].count == 4 {
                        collectionView.reloadData()
                        collectionView.reloadSections([0])
                    } else {
                        collectionView.deleteItems(at: [indexPath])
                    }
                    
                }, completion: nil)
            }
            actionSheetController.addAction(removePictureAction)
            
            //Present the AlertController
            self.present(actionSheetController, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.height, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        let inset = (collectionView.frame.size.width - collectionView.frame.size.height)/2
        return UIEdgeInsetsMake(0, inset, 0, inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minSpacing
    }
    
    
}

extension UIImage {
    func resizeWith(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    func resizeWith(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}
