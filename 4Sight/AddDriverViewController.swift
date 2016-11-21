//
//  AddDriverViewController.swift
//  4Sight
//
//  Created by Simon Withington on 16/06/2016.
//  Copyright © 2016 Appitized. All rights reserved.
//

import UIKit

class AddDriverViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var txtVehicleReg: UITextField!
    @IBOutlet weak var txtDriversName: UITextField!
    @IBOutlet weak var txtVehicleInsurance: UITextField!
    @IBOutlet weak var txtInsurancePolicy: UITextField!
    var callback: (([String: String])->())?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
//        guard let path = Bundle.main.path(forResource: "AddDriverForm", ofType:"plist") else {
//            debugPrint("Error: Unable to locate AddDriverForm.plist!")
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
        
        if let callback = callback {
            
            if txtVehicleReg.text != "" && txtDriversName.text != "" {
                var driver: [String:String] = [:]
                
                driver["registration_number"] = txtVehicleReg.text!
                driver["driver_name"] = txtDriversName.text!
                driver["insurance_company"] = "\(txtVehicleInsurance.text ?? "")"
                driver["insurance_policy_number"] = "\(txtInsurancePolicy.text ?? "")"
                
                callback(driver)
            }else{
                let errorAlert = UIAlertController(title: "Error", message: "Please ensure that all required fields are filled", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // also need to add a return button to the number pad?
        if textField == txtVehicleReg {
            txtDriversName.becomeFirstResponder()
        } else if textField == txtDriversName {
            txtVehicleInsurance.becomeFirstResponder()
        } else if textField == txtVehicleInsurance {
            txtInsurancePolicy.becomeFirstResponder()
        } else if textField == txtInsurancePolicy {
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
    }
}
