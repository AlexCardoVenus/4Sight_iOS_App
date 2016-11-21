//
//  AddWitnessViewController.swift
//  4Sight
//
//  Created by Simon Withington on 03/06/2016.
//  Copyright © 2016 Appitized. All rights reserved.
//

import UIKit

class AddWitnessViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtContactNumber: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var txtPostcode: UITextField!

    var addWitnessCallback: (([String: String])->())?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
//        
//        guard let path = Bundle.main.path(forResource: "AddWitnessForm", ofType:"plist") else {
//            debugPrint("Error: Unable to locate AddWitnessForm.plist!")
//            return
//        }
        
//        self.form = Form(formDataPath: path)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        addButton.layer.cornerRadius = 10
        addButton.layer.borderWidth = 3
        addButton.layer.borderColor = UIColor.white.cgColor
        addButton.layer.masksToBounds = true
    }
    
    @IBAction func addButtonPressed(_ sender: AnyObject) {
        
        if let callback = addWitnessCallback {
            
            if txtFirstName.text != "" && txtLastName.text != "" && txtContactNumber.text != "" {
                var witness: [String:String] = [:]
                
                witness["name"] = "\(txtFirstName.text!) \(txtLastName.text!)"
                witness["telephone_number"] = txtContactNumber.text!
                witness["address"] = "\(txtAddress.text ?? ""), \(txtPostcode.text ?? "")"
                
                callback(witness)
            }else{
                let errorAlert = UIAlertController(title: "Error", message: "Please ensure that all required fields are filled", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
            }
        }
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // also need to add a return button to the number pad?
        if textField == txtFirstName {
            txtLastName.becomeFirstResponder()
        } else if textField == txtLastName {
            txtContactNumber.becomeFirstResponder()
        } else if textField == txtContactNumber {
            txtAddress.becomeFirstResponder()
        } else if textField == txtAddress {
            txtPostcode.becomeFirstResponder()
        } else if textField == txtPostcode {
            textField.resignFirstResponder()
        }
        
        return false
    }
    
    @IBAction func backButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }
}
