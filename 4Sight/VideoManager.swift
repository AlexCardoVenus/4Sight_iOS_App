//
//  VideoManager.swift
//  4Sight
//
//  Created by Simon Rowlands on 22/06/2016.
//  Copyright © 2016 Appitized. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class VideoManager: NSObject, AVCaptureFileOutputRecordingDelegate {
    
    static let sharedInstance = VideoManager()
    var recordingStateBegunCallback: (()->())?
    var recordingStateEndedCallback: ((URL, Error?)->())?

    var updateOrientationCallback: (() -> ())?

    let sessionQueue = DispatchQueue(label: "session queue")
    let captureSession = AVCaptureSession()
    var backgroundRecordingID = UIBackgroundTaskInvalid
    var errorStrings = [String]()
    
    var authorized = true
    var audio_authorized = true
    var setupCompleted = false
    var setupSucceeded = true

    var videoDeviceInput: AVCaptureDeviceInput?
    var audioDeviceInput: AVCaptureDeviceInput?
    var movieFileOutput : AVCaptureMovieFileOutput?
    let uploadVideoFileType = AVFileTypeMPEG4
    
    static let timescale: CMTimeScale = 1000
    let recordingDuration = CMTimeMakeWithSeconds(20, timescale)
    
    func initialize() {
        authorized = true
        audio_authorized = true
        setupCompleted = false
        setupSucceeded = true
        
    }
    
    func checkVideoAuthStatus() {
        
        switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) {
            
        case AVAuthorizationStatus.authorized:
            break
            
        case AVAuthorizationStatus.notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: {
                [weak self] (accessGranted) in
                    if let weakSelf = self {
                        if !accessGranted {
                            weakSelf.authorized = false
                        }
                        weakSelf.sessionQueue.resume()
                    }
                }
            )
            break
            
        default:
            authorized = false
            break
        }
    }
    
    func checkAudioAuthStatus() {
        
        switch AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeAudio) {
            
        case AVAuthorizationStatus.authorized:
            break
            
        case AVAuthorizationStatus.notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeAudio, completionHandler: {
                [weak self] (accessGranted) in
                if let weakSelf = self {
                    if !accessGranted {
                        weakSelf.audio_authorized = false
                    }
                    weakSelf.sessionQueue.resume()
                }
                }
            )
            break
            
        default:
            audio_authorized = false
            break
        }
    }
    
    func setupCaptureSession() {
        sessionQueue.async { [weak self] in
            if let weakSelf = self {
                if !weakSelf.authorized {
                    return
                }
                
                weakSelf.backgroundRecordingID = UIBackgroundTaskInvalid
                
                weakSelf.captureSession.beginConfiguration()
                
                
                let videoDevice = AVCaptureDevice.devices().filter({ (device) -> Bool in
                    if let device = device as? AVCaptureDevice,
                        device.hasMediaType(AVMediaTypeVideo) && device.position == AVCaptureDevicePosition.back {
                        return true
                    }
                    return false
                }).first as! AVCaptureDevice
                
                var videoDeviceInput: AVCaptureDeviceInput?
                
                do {
                    videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                } catch {
                    weakSelf.errorStrings.append("Could not create video device input!")
                    weakSelf.setupSucceeded = false
                }
                
                if let videoDeviceInput = videoDeviceInput,
                    weakSelf.captureSession.canAddInput(videoDeviceInput) {
                    
                    weakSelf.captureSession.addInput(videoDeviceInput)
                    weakSelf.videoDeviceInput = videoDeviceInput
                    
                    DispatchQueue.main.async(execute: {
                        weakSelf.updateOrientationCallback!()
                    })
                } else {
                    weakSelf.errorStrings.append("Could not add video device input to the session!")
                    weakSelf.setupSucceeded = false
                }
                
                if weakSelf.audio_authorized == true {
                    let audioDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
                    var audioDeviceInput: AVCaptureDeviceInput?
                    
                    do {
                        audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
                    } catch {
                        weakSelf.errorStrings.append("Could not create audio device input!")
                        weakSelf.setupSucceeded = false
                    }
                    
                    if let audioDeviceInput = audioDeviceInput,
                        weakSelf.captureSession.canAddInput(audioDeviceInput) {
                        
                        weakSelf.captureSession.addInput(audioDeviceInput)
                        weakSelf.audioDeviceInput = audioDeviceInput
                    } else {
                        weakSelf.errorStrings.append("Could not add audio device input to the session!")
                        weakSelf.setupSucceeded = false
                    }
                }
                
                let movieFileOutput = AVCaptureMovieFileOutput()
                if weakSelf.captureSession.canAddOutput(movieFileOutput) {
                    
                    weakSelf.captureSession.addOutput(movieFileOutput)
                    let connection = movieFileOutput.connection(withMediaType: AVMediaTypeVideo)
                    if ((connection?.isVideoStabilizationSupported) != nil) {
                        connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
                    }
                    weakSelf.movieFileOutput = movieFileOutput
                } else {
                    weakSelf.errorStrings.append("Could not add movie file output to the session!")
                    weakSelf.setupSucceeded = false
                }
                
                for errorString in weakSelf.errorStrings {
                    debugPrint(errorString)
                }
                
                if weakSelf.captureSession.canSetSessionPreset(AVAssetExportPreset960x540) {
                    weakSelf.captureSession.sessionPreset = AVAssetExportPreset960x540
                }
                
                weakSelf.captureSession.commitConfiguration()
                weakSelf.setupCompleted = true
            }
        }
    }
    
    func startSession(completion: @escaping ((Bool)->())) {
        
        sessionQueue.async { [weak self] in
            
            if let weakSelf = self, weakSelf.setupCompleted {
                
                if weakSelf.setupSucceeded {
                    weakSelf.captureSession.startRunning()
                    completion(true)
                } else {
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
    }
    
    func startRecording(completion:@escaping ()->()) {
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        sessionQueue.async {
            if let movieFileOutput = self.movieFileOutput {
                if UIDevice.current.isMultitaskingSupported {
                    self.backgroundRecordingID = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                }
                
                completion()
                if let device = self.videoDeviceInput?.device,
                    device.hasFlash {
                    do {
                        try device.lockForConfiguration()
                        device.flashMode = AVCaptureFlashMode.off
                        device.unlockForConfiguration()
                    } catch {
                        debugPrint("Could not lock video input device for configuration")
                    }
                }
                
                let outputFileName = ProcessInfo.processInfo.globallyUniqueString + ".mov"
                let outputURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(outputFileName)
                movieFileOutput.startRecording(toOutputFileURL: outputURL, recordingDelegate: self)
                
                
            }
        }
    }
    
    func stopRecording() {
        
        sessionQueue.async { [weak self] in
            if let weakSelf = self, let movieFileOutput = weakSelf.movieFileOutput {
                movieFileOutput.stopRecording()
            }
        }
    }
    
    func cleanupBlock(url: URL) -> ()->() {
        
        let currentBackgroundRecordingID = backgroundRecordingID
        backgroundRecordingID = UIBackgroundTaskInvalid
        
        return {
            do {
                try FileManager.default.removeItem(at: url)
                if currentBackgroundRecordingID != UIBackgroundTaskInvalid {
                    UIApplication.shared.endBackgroundTask(currentBackgroundRecordingID)
                }
            } catch {
                // This is OK.
            }
        }
    }

    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        
        debugPrint("Did start recording to file: \(fileURL.absoluteString)")
        
        recordingStateBegunCallback?()
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        recordingStateEndedCallback?(outputFileURL, error)
    }
    
    func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let urlAsset = AVURLAsset(url: inputURL, options: nil)
        guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
            handler(nil)
            
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileTypeQuickTimeMovie
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
    
    func processVideo(url: URL, completion:@escaping ((URL?, Error?)->())) {
        
        let videoAsset = AVAsset(url: url)
        let outputFileName = ProcessInfo.processInfo.globallyUniqueString + "." + uploadVideoFileExtension
        let outputURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(outputFileName)
        
        if let exportSession = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPreset960x540) {
            
            exportSession.outputURL = outputURL
            exportSession.outputFileType = uploadVideoFileType
            
            if videoAsset.duration > recordingDuration {
                let range = CMTimeRangeMake(videoAsset.duration - recordingDuration, recordingDuration)
                
                exportSession.timeRange = range
            }
            
            exportSession.exportAsynchronously(completionHandler: { 
                
                switch exportSession.status {
                    
                case .failed:
                    completion(nil, exportSession.error)
                    break
                    
                case .cancelled:
                    debugPrint("Export Cancelled")
                    break
                    
                case .completed:
                    
                    guard let data = NSData(contentsOf: outputURL as URL) else {
                        debugPrint("Video is empty")
                        return
                    }
                    
                    print("File size before compression: \(Double(data.length / 1048576)) mb")
                    let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".m4v")
                    
                    self.compressVideo(inputURL: outputURL as URL, outputURL: compressedURL) { (exportSession) in
                        guard let session = exportSession else {
                            return
                        }
                        
                        switch session.status {
                        case .unknown:
                            break
                        case .waiting:
                            break
                        case .exporting:
                            break
                        case .completed:
                            guard let compressedData = NSData(contentsOf: compressedURL) else {
                                return
                            }
                            completion(compressedURL, nil)
                            print("File size after compression: \(Double(compressedData.length / 1048576)) mb")
                        case .failed:
                            debugPrint("Failed Compression")
                            break
                        case .cancelled:
                            break
                        }
                    }
                    break
                    
                default:
                    debugPrint("Unhandled case in exportSession.exportAsync completion switch!")
                    break
                }
            })
        } else {
            debugPrint("Error creating AVAssetExportSession")
        }
    }
}

extension AVCaptureVideoOrientation {
    
    static func mappedfromUIInterfaceOrientation(_ orientation:UIInterfaceOrientation) -> AVCaptureVideoOrientation {
        return [
            UIInterfaceOrientation.landscapeLeft:       AVCaptureVideoOrientation.landscapeLeft,
            UIInterfaceOrientation.landscapeRight:      AVCaptureVideoOrientation.landscapeRight,
            UIInterfaceOrientation.portrait:            AVCaptureVideoOrientation.landscapeLeft,
            UIInterfaceOrientation.portraitUpsideDown:  AVCaptureVideoOrientation.landscapeLeft,
            UIInterfaceOrientation.unknown:             AVCaptureVideoOrientation.landscapeLeft
            ][orientation]!
    }
    
    static func mappedfromUIDeviceOrientation(_ orientation:UIDeviceOrientation) -> AVCaptureVideoOrientation {
        return [
            UIDeviceOrientation.landscapeLeft:       AVCaptureVideoOrientation.landscapeRight,
            UIDeviceOrientation.landscapeRight:      AVCaptureVideoOrientation.landscapeLeft,
            UIDeviceOrientation.portrait:            AVCaptureVideoOrientation.landscapeRight,
            UIDeviceOrientation.portraitUpsideDown:  AVCaptureVideoOrientation.landscapeRight,
            UIDeviceOrientation.unknown:             AVCaptureVideoOrientation.landscapeRight
            ][orientation]!
    }
}
