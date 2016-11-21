//
//  VehicleDetailsViewController.swift
//  4Sight
//
//  Created by Simon Withington on 01/06/2016.
//  Copyright © 2016 Appitized. All rights reserved.
//

import UIKit

class VehicleDetailsViewController: FormViewController {

    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var vehicleRegText: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        submitButton.layer.cornerRadius = 10
        submitButton.layer.borderWidth = 3
        submitButton.layer.borderColor = UIColor.white.cgColor
        submitButton.layer.masksToBounds = true
    }
    
    @IBAction func submitButtonPressed() {
        guard let registrationNumber = vehicleRegText.text, registrationNumber.characters.count > 0 else {
            
            let alertController = UIAlertController(title: nil, message: "Please enter a valid registration number", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertController, animated: true, completion:nil)
            
            return
        }
        
        IncidentService.sharedInstance.currentIncident.registrationNumber = registrationNumber
        
        LoadingIndicator.show(targetView:view)
        
        IncidentService.reportIncident {
            [weak self] (error) in
            
            LoadingIndicator.hide()
            
            if let error = error {
                debugPrint(error) // TODO: Handle this better if we have no network access?
                
                if let weakSelf = self {
                    let confirmationAlert = UIAlertController(title: "Error", message: error.userInfo["message"] as! String?, preferredStyle: .alert)
                    
                    if error.userInfo["message"] == nil {
                        confirmationAlert.message = error.userInfo["NSLocalizedDescription"] as! String?
                    }
                    
                    confirmationAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    weakSelf.present(confirmationAlert, animated: true, completion: nil)
                }
            } else if let weakSelf = self {
                weakSelf.performSegue(withIdentifier: "showDriverDetails", sender: self)
            }
        }
    }
}
