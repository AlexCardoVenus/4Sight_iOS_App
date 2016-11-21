//
//  AccountViewController.swift
//  4Sight
//
//  Created by Simon Withington on 05/05/2016.
//  Copyright © 2016 Appitized. All rights reserved.
//

import UIKit

class AccountViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtSurname: UITextField!
    @IBOutlet weak var txtVehicleReg: UITextField!
    @IBOutlet weak var txtMobileNumber: UITextField!
    @IBOutlet weak var txtEmailAddress: UITextField!
    @IBOutlet weak var txtPostalAddress: UITextField!
    @IBOutlet weak var txtInsurer: UITextField!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
//        guard let path = Bundle.main.path(forResource: "AccountForm", ofType:"plist") else {
//            debugPrint("Error: Unable to locate AccountForm.plist!")
//            return
//        }
        
//        self.form = Form(formDataPath: path)
        
//        self.form?.formData?[0][0]["initial"] = UserService.sharedInstance.currentUser?.firstName
//        self.form?.formData?[0][1]["initial"] = UserService.sharedInstance.currentUser?.surname
//        self.form?.formData?[0][2]["initial"] = UserService.sharedInstance.currentUser?.vehicleRegistration
//        self.form?.formData?[0][3]["initial"] = UserService.sharedInstance.currentUser?.telephoneNumber
//        self.form?.formData?[0][4]["initial"] = UserService.sharedInstance.currentUser?.email
//        self.form?.formData?[0][5]["initial"] = UserService.sharedInstance.currentUser?.address
//        self.form?.formData?[0][6]["initial"] = UserService.sharedInstance.currentUser?.insurer
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        txtFirstName.text = UserService.sharedInstance.currentUser?.firstName
        txtSurname.text = UserService.sharedInstance.currentUser?.surname
        txtVehicleReg.text = UserService.sharedInstance.currentUser?.vehicleRegistration
        txtMobileNumber.text = UserService.sharedInstance.currentUser?.telephoneNumber
        txtEmailAddress.text = UserService.sharedInstance.currentUser?.email
        txtPostalAddress.text = UserService.sharedInstance.currentUser?.address
        txtInsurer.text = UserService.sharedInstance.currentUser?.insurer
        
        saveButton.layer.cornerRadius = 10
        saveButton.layer.borderWidth = 3
        saveButton.layer.borderColor = UIColor.white.cgColor
        saveButton.layer.masksToBounds = true
        
    }
    
    @IBAction func saveButtonPressed(_ sender: AnyObject) {
        
        if txtFirstName.text != "" && txtSurname.text != "" && txtVehicleReg.text != "" && txtMobileNumber.text != "" && txtEmailAddress.text != "" && txtPostalAddress.text != "" && txtInsurer.text != "" {

            var formDict = [String: String]()
            
            formDict["first_name"] = txtFirstName.text!
            formDict["surname"] = txtSurname.text!
            formDict["vehicle_registration"] = txtVehicleReg.text!
            formDict["telephone_number"] = txtMobileNumber.text!
            formDict["email"] = txtEmailAddress.text!
            formDict["address"] = txtPostalAddress.text!
            formDict["insurer"] = txtInsurer.text!

            
            LoadingIndicator.show(targetView: view)
            UserService.updateUserDetails(formDict, completion: {
                [weak self] (error) in
                
                LoadingIndicator.hide()
                
                if let error = error, let weakSelf = self, let errorInfo = error.userInfo as? [String: String] {
                
                let confirmationAlert = UIAlertController(title: nil, message: errorInfo["error_description"], preferredStyle: .alert)
                confirmationAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                weakSelf.present(confirmationAlert, animated: true, completion: nil)
                
                } else if let _ = UserService.sharedInstance.currentUser, let weakSelf = self {
                    UserService.getUserDetails({
                        (error) in
                        if error != nil {
                            
                        } else {
                            UserService.saveCurrentUser()
                            let confirmationAlert = UIAlertController(title: nil, message: "Account details have been updated successfully!", preferredStyle: .alert)
                            confirmationAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                            weakSelf.present(confirmationAlert, animated: true, completion: nil)
                        }
                    })
                }
            })
        }else{
            let errorAlert = UIAlertController(title: "Error", message: "Please ensure that all fields are filled", preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(errorAlert, animated: true, completion: nil)
        }
    }
    
        
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // also need to add a return button to the number pad?
        if textField == txtFirstName {
            txtSurname.becomeFirstResponder()
        } else if textField == txtSurname {
            txtVehicleReg.becomeFirstResponder()
        } else if textField == txtVehicleReg {
            txtMobileNumber.becomeFirstResponder()
        } else if textField == txtMobileNumber {
            txtEmailAddress.becomeFirstResponder()
        } else if textField == txtEmailAddress {
            txtPostalAddress.becomeFirstResponder()
        } else if textField == txtPostalAddress {
            txtInsurer.becomeFirstResponder()
        } else if textField == txtInsurer {
            txtInsurer.resignFirstResponder()
        }
        
        return false
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.size.height == UIScreen.main.bounds.size.height {
                self.view.frame.size.height -= keyboardSize.height
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.size.height != UIScreen.main.bounds.size.height{
                self.view.frame.size.height += keyboardSize.height
            }
        }
    }
    
    @IBAction func backButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
}
