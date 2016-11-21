//
//  ChangePasswordViewController.swift
//  4Sight
//
//  Created by Alex Cardo on 10/3/16.
//  Copyright © 2016 Appitized. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var txtCurrentPassword: UITextField!
    @IBOutlet weak var txtNewPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        guard let path = Bundle.main.path(forResource: "ChangePassForm", ofType:"plist") else {
//            debugPrint("Error: Unable to locate ChangePassForm.plist!")
//            return
//        }
        
//        self.form = Form(formDataPath: path)
        
        saveButton.layer.cornerRadius = 10
        saveButton.layer.masksToBounds = true
        saveButton.layer.borderColor = UIColor.white.cgColor
        saveButton.layer.borderWidth = 3
    }
    
    
    @IBAction func saveButtonPressed(_ sender: AnyObject) {
        
        if txtCurrentPassword.text != "" && txtNewPassword.text != "" && txtConfirmPassword.text != "" {
            var formDict = [String: String]()
            
            formDict["current_password"] = txtCurrentPassword.text!
            formDict["new_password"] = txtNewPassword.text!
            formDict["new_password_confirmation"] = txtConfirmPassword.text!
            
            LoadingIndicator.show(targetView: view)
            UserService.changePassword(formDict, completion: {
                [weak self] (error) in
                
                LoadingIndicator.hide()
                
                if let error = error, let weakSelf = self  {
                    if error.code == 403 {
                        let confirmationAlert = UIAlertController(title: nil, message: "Current password is invalid!", preferredStyle: .alert)
                        confirmationAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        weakSelf.present(confirmationAlert, animated: true, completion: nil)
                    } else {
                        let errorInfo = error.userInfo as? [String: AnyObject]
                        
                        let error_message = errorInfo?.values.first as? [String]
                        
                        
                        let confirmationAlert = UIAlertController(title: nil, message: error_message?[0] , preferredStyle: .alert)
                        confirmationAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        weakSelf.present(confirmationAlert, animated: true, completion: nil)
                    }
                } else if let _ = UserService.sharedInstance.currentUser, let weakSelf = self {
                    let confirmationAlert = UIAlertController(title: nil, message: "Password has been changed!" , preferredStyle: .alert)
                    confirmationAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    weakSelf.present(confirmationAlert, animated: true, completion: nil)
                }
            })
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == txtCurrentPassword {
            txtNewPassword.becomeFirstResponder()
        } else if textField == txtNewPassword {
            txtConfirmPassword.becomeFirstResponder()
        } else if textField == txtConfirmPassword {
            textField.resignFirstResponder()
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
    }}
