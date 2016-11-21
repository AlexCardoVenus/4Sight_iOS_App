//
//  YourVehicleViewController.swift
//  4Sight
//
//  Created by Simon Withington on 20/05/2016.
//  Copyright © 2016 Appitized. All rights reserved.
//

import UIKit

class YourVehicleViewController: UIViewController {

    @IBOutlet weak var registrationView: UIView!
    @IBOutlet weak var registrationBorderView: UIView!
    @IBOutlet weak var registrationLabel: UILabel!
    
    @IBOutlet weak var otherVehicleButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        registrationView.layer.cornerRadius = 5
        registrationView.layer.masksToBounds = true
        registrationView.layer.borderColor = UIColor.black.cgColor
        registrationView.layer.borderWidth = 2
        
        registrationBorderView.layer.cornerRadius = 5
        registrationBorderView.layer.masksToBounds = true
        registrationBorderView.layer.borderColor = UIColor.black.cgColor
        registrationBorderView.layer.borderWidth = 3
        
        otherVehicleButton.layer.cornerRadius = 10
        otherVehicleButton.layer.masksToBounds = true
        otherVehicleButton.layer.borderColor = UIColor.white.cgColor
        otherVehicleButton.layer.borderWidth = 3
        
        confirmButton.layer.cornerRadius = 10
        confirmButton.layer.masksToBounds = true
        confirmButton.layer.borderColor = UIColor.white.cgColor
        confirmButton.layer.borderWidth = 3
        
        registrationLabel.text = UserService.sharedInstance.currentUser?.vehicleRegistration
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: IBActions
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmButtonPressed(_ sender: AnyObject) {
        
        guard let registrationNumber = registrationLabel.text, registrationNumber.characters.count > 0 else {
            
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
    
    @IBAction func noButtonPressed(_ sender: AnyObject) {
        
        guard let registrationNumber = registrationLabel.text, registrationNumber.characters.count > 0 else {
            
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
