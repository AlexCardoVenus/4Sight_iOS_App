//
//  DriverDetailsViewController.swift
//  4Sight
//
//  Created by Simon Withington on 16/06/2016.
//  Copyright © 2016 Appitized. All rights reserved.
//

import UIKit

class DriverDetailsViewController: UIViewController,  UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    var drivers: [[String: String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        submitButton.layer.cornerRadius = 10
        submitButton.layer.borderWidth = 3
        submitButton.layer.borderColor = UIColor.white.cgColor
        submitButton.layer.masksToBounds = true
    }
    
    @IBAction func addDriverButtonPressed(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "addDriverSegue", sender: self)
    }
    
    @IBAction func submitButtonPressed(_ sender: AnyObject) {
    
        if drivers.count > 0 {
            
            LoadingIndicator.show(targetView: view)
            IncidentService.addVehicles(drivers: drivers, completion: {
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
                    weakSelf.performSegue(withIdentifier: "showCrashEvidence", sender: weakSelf)
                }
            })
        } else {
            performSegue(withIdentifier: "showCrashEvidence", sender: self)
        }
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addDriverVC = segue.destination as? AddDriverViewController {
            addDriverVC.callback = {
                [weak self] (driver) in
                
                if let weakSelf = self {
                    weakSelf.drivers.append(driver)
                    
                    DispatchQueue.main.async(execute: {
                        weakSelf.tableView.reloadData()
                        weakSelf.dismiss(animated: true, completion: nil)
                    })
                }
            }
        }
    }
    
    
    // MARK: TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return drivers.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell
        
        if (indexPath as NSIndexPath).row >= drivers.count {
            cell = tableView.dequeueReusableCell(withIdentifier: "addDriverCell")!
            
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "driverCell")!
            
            if let titleLabel = cell.viewWithTag(1) as? UILabel! {
                titleLabel.text = "Driver \((indexPath as NSIndexPath).row+1)"
            }
            if let nameLabel = cell.viewWithTag(2) as? UITextField!, let name = drivers[(indexPath as NSIndexPath).row]["driver_name"] {
                nameLabel.text = name
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if indexPath.row != drivers.count {
            return true
        }else{
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete
            
            drivers.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
