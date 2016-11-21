//
//  SubscriptionViewController.swift
//  4Sight
//
//  Created by Alex Cardo on 10/3/16.
//  Copyright © 2016 Appitized. All rights reserved.
//

import UIKit
import StoreKit

class SubscriptionViewController: UIViewController {
    
    
    @IBOutlet weak var payButton: UIButton!
    var products = [SKProduct]()
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        payButton.layer.cornerRadius = 10
        payButton.layer.masksToBounds = true
        payButton.layer.borderColor = UIColor.white.cgColor
        payButton.layer.borderWidth = 3
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
//        products = []
        
//        IAPProducts.store.requestProducts { success, products in
//            if success {
//                self.products = products!
//                debugPrint(self.products)
//            }
//            
//        }
//        
//        NotificationCenter.default.addObserver(
//            self,
//            selector: #selector(SubscriptionViewController.finishedPayment),
//            name: NSNotification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification),
//            object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func finishedPayment() {
        
//            var storage: UserDefaults
//            
//            var newReceipt = transacti
//            
//            NSUserDefaults *storage = [NSUserDefaults standardUserDefaults];
//
//            NSData *newReceipt = transaction.transactionReceipt;
//            NSArray *savedReceipts = [storage arrayForKey:@"receipts"];
//            if (!savedReceipts) {
//                // Storing the first receipt
//                [storage setObject:@[newReceipt] forKey:@"receipts"];
//            } else {
//                // Adding another receipt
//                NSArray *updatedReceipts = [savedReceipts arrayByAddingObject:newReceipt];
//                [storage setObject:updatedReceipts forKey:@"receipts"];
//            }
//
//            [storage synchronize];
            

            debugPrint("unwindToDashboardWithSegue")
            self.performSegue(withIdentifier: "unwindToDashboardWithSegue", sender: self)
    }
    
    
    @IBAction func payButtonPressed(_ sender: AnyObject) {
        
//        for product: SKProduct in products {
//            if product.productIdentifier == "com.4Sight.iap.subscription.monthly" {
//                IAPProducts.store.buyProduct(product)
//            }
//        }
    }
    
}
