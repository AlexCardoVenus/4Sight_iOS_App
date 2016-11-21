//
//  EvidenceCollectionViewCell.swift
//  4Sight
//
//  Created by Simon Withington on 01/06/2016.
//  Copyright © 2016 Appitized. All rights reserved.
//

import UIKit

class EvidenceCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    class func reuseIdentifier() -> String {
        return "evidenceCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
}
