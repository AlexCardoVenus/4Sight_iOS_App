//
//  WitnessDetailsViewController.swift
//  4Sight
//
//  Created by Simon Withington on 03/06/2016.
//  Copyright © 2016 Appitized. All rights reserved.
//

import UIKit
import AVFoundation

class WitnessDetailsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var returnButton: UIButton!
    
    @IBOutlet weak var tintView: UIView!
    
    var player: AVAudioPlayer?
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    var witnesses: [[String: String]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        submitButton.layer.cornerRadius = 10
        submitButton.layer.borderWidth = 3
        submitButton.layer.borderColor = UIColor.white.cgColor
        submitButton.layer.masksToBounds = true
        
        /* 2016-10-4 by Alex */
        successView.layer.cornerRadius = 6
        returnButton.layer.cornerRadius = 10
        returnButton.layer.borderWidth = 3
        returnButton.layer.borderColor = UIColor.orange.cgColor
        returnButton.layer.masksToBounds = true
    }
    
    @IBAction func addWitnessButtonPressed(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "addWitnessSegue", sender: self)
    }

    @IBAction func submitButtonPressed(_ sender: AnyObject) {
        
        if witnesses.count > 0 {
        IncidentService.addWitnesses(witnesses: witnesses, completion: {
            [weak self] (error) in
            
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
                weakSelf.successView.isHidden = false
                weakSelf.tintView.isHidden = false
                
                let url = Bundle.main.url(forResource: "Upload Alert_V3", withExtension: "mp3")!
                
                do {
                    self?.player = try AVAudioPlayer(contentsOf: url)
                    guard let player = self?.player else { return }
                    
                    player.prepareToPlay()
                    player.play()
                } catch let error as NSError {
                    print(error.description)
                }
                
                //weakSelf.performSegue(withIdentifier: "unwindToDashboard", sender: weakSelf)
            }
            })
        } else {
            self.successView.isHidden = false
            self.tintView.isHidden = false
            
            let url = Bundle.main.url(forResource: "Upload Alert_V3", withExtension: "mp3")!
            
            do {
                self.player = try AVAudioPlayer(contentsOf: url)
                guard let player = self.player else { return }
                
                player.prepareToPlay()
                player.play()
            } catch let error as NSError {
                print(error.description)
            }
            
            //performSegue(withIdentifier: "unwindToDashboard", sender: self)
        }
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func returnButtonPressed(_ sender: AnyObject) {
        successView.isHidden = true
        tintView.isHidden = true
        
        performSegue(withIdentifier: "unwindToDashboard", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let addWitnessVC = segue.destination as? AddWitnessViewController {
            addWitnessVC.addWitnessCallback = {
                [weak self] (witness) in
                
                if let weakSelf = self {
                    weakSelf.witnesses.append(witness)
                    
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
        return witnesses.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell
        
        if (indexPath as NSIndexPath).row >= witnesses.count {
            cell = tableView.dequeueReusableCell(withIdentifier: "addWitnessCell")!
            
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "witnessCell")!
            
            if let titleLabel = cell.viewWithTag(1) as? UILabel! {
                titleLabel.text = "Witness \((indexPath as NSIndexPath).row+1)"
            }
            if let nameLabel = cell.viewWithTag(2) as? UITextField!, let name = witnesses[(indexPath as NSIndexPath).row]["name"] {
                nameLabel.text = name
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if indexPath.row != witnesses.count {
            return true
        }else{
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete
            
            witnesses.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}
