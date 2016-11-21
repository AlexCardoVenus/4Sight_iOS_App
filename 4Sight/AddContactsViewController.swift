//
//  AddContactsViewController.swift
//  4Sight
//
//  Created by Simon Rowlands on 08/11/2016.
//  Copyright © 2016 Appitized. All rights reserved.
//

import UIKit
import Contacts

class AddContactsViewController: UIViewController {
    
    @IBOutlet weak var btnNo: UIButton!
    @IBOutlet weak var btnYes: UIButton!
    
    var store = CNContactStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btnNo.layer.cornerRadius = 10
        btnNo.layer.borderWidth = 3
        btnNo.layer.borderColor = UIColor.white.cgColor
        btnNo.layer.masksToBounds = true
        
        btnYes.layer.cornerRadius = 10
        btnYes.layer.borderWidth = 3
        btnYes.layer.borderColor = UIColor.white.cgColor
        btnYes.layer.masksToBounds = true
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
    
    @IBAction func noButtonPressed(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "showDashboard", sender: self)
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
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "showDashboard", sender: self)
            }
            
        } catch let err{
            debugPrint("Failed to save the contact. \(err)")
        }
    }
}
