//
//  SignInViewController.swift
//  4Sight
//
//  Created by Simon Withington on 25/04/2016.
//  Copyright © 2016 Appitized. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var forgottenView: UIView!
    @IBOutlet weak var forgottenEmail: UITextField!
    @IBOutlet weak var loginEmail: UITextField!
    @IBOutlet weak var loginPassword: UITextField!

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
//        guard let path = Bundle.main.path(forResource: "SignInForm", ofType:"plist") else {
//            debugPrint("Error: Unable to locate SignInForm.plist!")
//            return
//        }
        
//        self.form = Form(formDataPath: path)
        
        submitButton.layer.cornerRadius = 10
        submitButton.layer.borderWidth = 3
        submitButton.layer.borderColor = UIColor.white.cgColor
        submitButton.layer.masksToBounds = true
    }
    
    @IBAction func forgottenButtonPressed(_ sender: AnyObject) {
//        print("forgotten")
//        var formDict = [String: String]()
//        
//        let allFormEntries = form?.allEntries(tableView: tableView)
//        
//        allFormEntries?.forEach({ (_, value, mapping) in
//            formDict[mapping] = value
//        })
//        
//        guard let email = formDict["email"] else {
//            return
//        }
//        
//        
//        forgottenEmail.text = email
        forgottenView.isHidden = false
        forgottenEmail.becomeFirstResponder()
    }
    
    @IBAction func recoverButtonPressed() {
        if forgottenEmail.text?.isEmpty == false {
            LoadingIndicator.show(targetView: view)
            UserService.resetPassword(forgottenEmail.text!, completion: {
                [weak self] (error) in
                
                LoadingIndicator.hide()
                
                if let error = error, let weakSelf = self, let errorInfo = error.userInfo as? [String: AnyObject] {
                    
                    let error_message = errorInfo.values.first as? [String]
                    
                    let confirmationAlert = UIAlertController(title: nil, message: error_message?[0] , preferredStyle: .alert)
                    confirmationAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    weakSelf.present(confirmationAlert, animated: true, completion: nil)
                    
                } else {// if let _ = UserService.sharedInstance.currentUser, let weakSelf = self {
                    //weakSelf.performSegue(withIdentifier: "showDashboard", sender: weakSelf)
                    self?.forgottenView.isHidden = true
                    self?.forgottenEmail.resignFirstResponder()
                    self?.forgottenView.endEditing(true)
                    
                    let confirmationAlert = UIAlertController(title: nil, message: "Request has been submitted successfully!" , preferredStyle: .alert)
                    confirmationAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self?.present(confirmationAlert, animated: true, completion: nil)
                }
            })
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        forgottenView.isHidden = true
        forgottenEmail.resignFirstResponder()
        forgottenView.endEditing(true)
    }
    
    
    @IBAction func signInButtonPressed(_ sender: AnyObject) {
        
//        var formDict = [String: String]()
        
//        let allFormEntries = form?.allEntries(tableView: tableView)
        
//        allFormEntries?.forEach({ (_, value, mapping) in
//            formDict[mapping] = value
//        })
        
        guard let email = loginEmail.text, let password = loginPassword.text else {
            return
        }
        
        LoadingIndicator.show(targetView: view)
        UserService.signIn(email, password: password, completion: {
            [weak self] (error) in
            
            LoadingIndicator.hide()
            
            if let error = error, let weakSelf = self {
                // handle this
                let confirmationAlert = UIAlertController(title: "Error", message: error.userInfo["message"] as! String?, preferredStyle: .alert)
                
                if error.userInfo["message"] == nil {
                    confirmationAlert.message = error.userInfo["NSLocalizedDescription"] as! String?
                }
                
                confirmationAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                weakSelf.present(confirmationAlert, animated: true, completion: nil)
            }
            else if let _ = UserService.sharedInstance.currentUser, let weakSelf = self {
                
                let defaults = UserDefaults.standard
                var loggedInOnThisDevice: [String] = [String]()
                var newUser: Bool = true
                
                if let previouslyLoggedIn : [String] = defaults.object(forKey: "previouslyLoggedInUsers") as? [String] {
                    // append email if new user
                    loggedInOnThisDevice = previouslyLoggedIn
                    
                    for item in loggedInOnThisDevice {
                        if item == email {
                            newUser = false
                        }
                    }
                    
                    if newUser == true {
                        loggedInOnThisDevice.append(email)
                    }
                } else {
                    // save new/first user
                    newUser = true
                    loggedInOnThisDevice.append(email)
                }
                
                defaults.set(loggedInOnThisDevice, forKey: "previouslyLoggedInUsers")
                defaults.synchronize()
                
                if newUser == true {
                    weakSelf.performSegue(withIdentifier: "showAddContacts", sender: weakSelf)
                }else{
                    weakSelf.performSegue(withIdentifier: "showDashboard", sender: weakSelf)
                }
            }
        })
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == loginEmail {
            loginPassword.becomeFirstResponder()
        }else if textField == forgottenEmail {
            recoverButtonPressed()
        } else{
            textField.resignFirstResponder()
        }
        
        return false
    }
    
    @IBAction func backButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
}
