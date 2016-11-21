//
//  FormViewController.swift
//  4Sight
//
//  Created by Simon Withington on 29/04/2016.
//  Copyright © 2016 Appitized. All rights reserved.
//

import UIKit

class FormViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    var form: Form? {
        didSet {
            if let form = self.form {
                self.tableView.dataSource = form
                self.tableView.delegate = form
                self.tableView.reloadData()
            }
        }
    }

    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /* 2016-10-7 by Alex */
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //if textField ==  || textField ==  {
        animateViewMoving(up: true, moveValue: 100)
        //}
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //if textField ==  || textField ==  {
        animateViewMoving(up: false, moveValue: 100)
        //}
    }
    
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    /* -------------------- */
    
    // MARK: IBActions
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
