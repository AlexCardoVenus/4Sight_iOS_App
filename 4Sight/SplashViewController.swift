//
//  SplashViewController.swift
//  4Sight
//
//  Created by Simon Withington on 25/04/2016.
//  Copyright © 2016 Appitized. All rights reserved.
//

import UIKit
import Photos

class SplashViewController: UIViewController {
    
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    let kShownTutorial = "shownTutorial"
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        signInButton.layer.cornerRadius = 10
        signInButton.layer.masksToBounds = true
        signInButton.layer.borderColor = UIColor.white.cgColor
        signInButton.layer.borderWidth = 3
        
        registerButton.layer.cornerRadius = 10
        registerButton.layer.masksToBounds = true
        registerButton.layer.borderColor = UIColor.white.cgColor
        registerButton.layer.borderWidth = 3
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        requestCameraRollAccess()
        
        if let shownTutorial = UserDefaults.standard.value(forKey: kShownTutorial) as? Bool, shownTutorial == true {
            
            UserService.loadCurrentUser()
            if let _ = UserService.sharedInstance.currentUser?.accessToken {
                performSegue(withIdentifier: "showDashboard", sender: self)
            }
        } else {
            UserDefaults.standard.setValue(true, forKey: kShownTutorial)
            showTutorial()
        }
    }
    
    @IBAction func tutorialButtonPressed(_ sender: AnyObject) {
        showTutorial()
    }
    
    func showTutorial() {
        
        let tutorialPageVC = TutorialPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        tutorialPageVC.exit = {
            [weak self] in
            if let weakSelf = self {
                weakSelf.dismiss(animated: true, completion: nil)
            }
        }
        
        present(tutorialPageVC, animated: true, completion: nil)
    }
    
    func requestCameraRollAccess() {
        
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                debugPrint("Authorized")
            case .restricted:
                let restrictedAlert = UIAlertController(title: "Restricted Access", message: "Access to the camera roll has been restricted, video recordings may not function.", preferredStyle: .alert)
                restrictedAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                
            case .denied:
                let deniedAlert = UIAlertController(title: "Denied Access", message: "Access to the camera roll has been denied, in order for the app to function please allow access in your settings.", preferredStyle: .alert)
                deniedAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                
            default:
                
                break
            }
        }
    }
}
