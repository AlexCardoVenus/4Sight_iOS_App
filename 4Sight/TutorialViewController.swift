//
//  TutorialViewController.swift
//  4Sight
//

import UIKit

class TutorialViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var exitButton: UIButton!
    var image: UIImage?
    var exit: (()->())?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let _ = exit {
            exitButton.isHidden = false
        }
        
        imageView.image = image
    }
    
    @IBAction func exitTutorial(_ sender: AnyObject) {
        exit?()
    }
}
