//
//  PreviewView.swift
//  4Sight
//
//  Created by Simon Withington on 28/04/2016.
//  Copyright © 2016 Appitized. All rights reserved.
//

import UIKit
import AVFoundation

class PreviewView: UIView {
    
    override public class var layerClass: Swift.AnyClass {
        get {
            return AVCaptureVideoPreviewLayer.classForCoder()
        }
    }
    
    var session: AVCaptureSession? {
        get {
            if let previewLayer = self.layer as? AVCaptureVideoPreviewLayer {
                return previewLayer.session
            } else {
                return nil
            }
        }
        set {
            if let previewLayer = self.layer as? AVCaptureVideoPreviewLayer {
                previewLayer.session = newValue
            }
        }
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer? {
        get {
            return self.layer as? AVCaptureVideoPreviewLayer ?? nil
        }
    }
}
