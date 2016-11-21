//
//  RegisterViewController.swift
//  4Sight
//
//  Created by Simon Withington on 29/04/2016.
//  Copyright © 2016 Appitized. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtSurname: UITextField!
    @IBOutlet weak var txtVehicleReg: UITextField!
    @IBOutlet weak var txtMobileNumber: UITextField!
    @IBOutlet weak var txtEmailAddress: UITextField!
    @IBOutlet weak var txtPostalAddress: UITextField!
    @IBOutlet weak var txtInsurer: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        submitButton.layer.cornerRadius = 10
        submitButton.layer.borderWidth = 3
        submitButton.layer.borderColor = UIColor.white.cgColor
        submitButton.layer.masksToBounds = true
        
    }
    
    @IBAction func termsBtnPressed(_ sender: AnyObject) {
        self.termsButton.isSelected = !self.termsButton.isSelected
    }

    @IBAction func gotoTermsView(_ sender: AnyObject) {
        
    }
    
    @IBAction func registerButtonPressed(_ sender: AnyObject) {
        
        if(!self.termsButton.isSelected) {
            let confirmationAlert = UIAlertController(title: nil, message: "Please accept Terms & Conditions" , preferredStyle: .alert)
            confirmationAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(confirmationAlert, animated: true, completion: nil)
        } else {
            var formDict = [String: String]()
            
            if txtFirstName.text != "" && txtSurname.text != "" && txtVehicleReg.text != "" && txtMobileNumber.text != "" && txtEmailAddress.text != "" && txtPostalAddress.text != "" && txtInsurer.text != "" && txtPassword.text != "" && txtConfirmPassword.text != "" {
            
                formDict["first_name"] = txtFirstName.text!
                formDict["surname"] = txtSurname.text!
                formDict["vehicle_registration"] = txtVehicleReg.text!
                formDict["telephone_number"] = txtMobileNumber.text!
                formDict["email"] = txtEmailAddress.text!
                formDict["address"] = txtPostalAddress.text!
                formDict["insurer"] = txtInsurer.text!
                formDict["password"] = txtPassword.text!
                formDict["password_confirmation"] = txtConfirmPassword.text!
                
                LoadingIndicator.show(targetView:view)
                
                UserService.registerUser(formDict) {
                    [weak self] (error) in
                    
                    LoadingIndicator.hide()
                    
                    if let weakSelf = self {
                        if let error = error, let errorInfo = error.userInfo as? [String: AnyObject] {
                            
                            let error_message = errorInfo.values.first as? [String]
                            
                            
                            let confirmationAlert = UIAlertController(title: nil, message: error_message?[0] , preferredStyle: .alert)
                            confirmationAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                            weakSelf.present(confirmationAlert, animated: true, completion: nil)
                            
                        } else if let _ = UserService.sharedInstance.currentUser {
                            weakSelf.performSegue(withIdentifier: "showAddContacts", sender: weakSelf)
                        }
                    }
                }
            } else {
                let errorAlert = UIAlertController(title: "Error", message: "Please ensure that all fields are filled", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
            txtPassword.becomeFirstResponder()
        } else if textField == txtPassword {
            txtConfirmPassword.becomeFirstResponder()
        } else if textField == txtConfirmPassword {
            txtConfirmPassword.resignFirstResponder()
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
