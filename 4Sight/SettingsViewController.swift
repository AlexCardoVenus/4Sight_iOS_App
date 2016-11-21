//
//  SettingsViewController.swift
//  4Sight
//
//  Created by Alex Cardo on 10/3/16.
//  Copyright © 2016 Appitized. All rights reserved.
//

import UIKit
import Contacts

class SettingsViewController: UIViewController {
    
    var store = CNContactStore()
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }

    
    @IBAction func logoutButtonPressed(_ sender: AnyObject) {
        UserService.logOut()
        
        VideoManager.sharedInstance.captureSession.stopRunning()
        VideoManager.sharedInstance.captureSession.removeInput(VideoManager.sharedInstance.videoDeviceInput)
        VideoManager.sharedInstance.captureSession.removeOutput(VideoManager.sharedInstance.movieFileOutput)
        VideoManager.sharedInstance.captureSession.removeInput(VideoManager.sharedInstance.audioDeviceInput)
        
        
        let rootViewController = self.storyboard!.instantiateViewController(withIdentifier: "splashVC") as? SplashViewController
        UIApplication.shared.keyWindow?.rootViewController = rootViewController
    }
    
    @IBAction func restorePurchases(_ sender: AnyObject) {
//        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(SettingsViewController.restoredSuccess),
//            name: NSNotification.Name(rawValue: "restorePurchases"),
//            object: nil)
//        
//        IAPProducts.store.restorePurchases()
    }
    
    @IBAction func addToContacts() {
        switch CNContactStore.authorizationStatus(for: .contacts){
        case .authorized:
            createContact()
        // This is the method we will create
        case .notDetermined:
            store.requestAccess(for: .contacts) { succeeded, err in
                guard err == nil && succeeded else{
                    return
                }
                self.createContact()
            }
        default:
            print("Not handled")
        }
    }
    
    func createContact() {
        let contactData = CNMutableContact()
        contactData.givenName = "4Sight"
        
        let workPhone = CNLabeledValue(label: CNLabelWork, value: CNPhoneNumber(stringValue: "0161 627 3700"))
        contactData.phoneNumbers = [workPhone]
        
        let request = CNSaveRequest()
        request.add(contactData, toContainerWithIdentifier: nil)
        
        do{
            try store.execute(request)
            debugPrint("Successfully added the contact")
            
            let confirmationAlert = UIAlertController(title: "Contacts", message: "Successfully added to contacts", preferredStyle: .alert)
            confirmationAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(confirmationAlert, animated: true, completion: nil)
            
        } catch let err{
            debugPrint("Failed to save the contact. \(err)")
        }
    }
    
    func restoredSuccess() {
        let alert = UIAlertController(title: "Restore Purchases", message: "Purchases restored successfully!", preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "Ok", style: .default)
        
        alert.addAction(confirm)
        
        present(alert, animated: true, completion: nil)
    }
}
