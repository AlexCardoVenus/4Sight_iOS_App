//
//  LoadingIndicator.swift
//  4Sight
//
//  Created by Simon Withington on 12/07/2016.
//  Copyright © 2016 Appitized. All rights reserved.
//

import UIKit

class LoadingIndicator {

    var view = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    private static let sharedInstance = LoadingIndicator()
    
    static func show(targetView: UIView) {
        sharedInstance.show(targetView: targetView)
    }
    
    static func hide() {
        sharedInstance.hide()
    }
    
    func show(targetView: UIView) {
        view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        targetView.addSubview(view)
    }
    
    func hide() {
        activityIndicator.stopAnimating()
        view.removeFromSuperview()
    }
}
