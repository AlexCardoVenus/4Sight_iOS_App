//
//  SubscriptionViewController.swift
//  4Sight
//
//  Created by Alex Cardo on 10/25/16.
//  Copyright © 2016 Appitized. All rights reserved.
//

import UIKit

class TermsAndConditionsViewController: UIViewController {
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    

    @IBAction func backBtnPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
