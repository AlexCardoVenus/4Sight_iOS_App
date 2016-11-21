//
//  DashboardViewController.swift
//  4Sight
//
//  Created by Simon Withington on 26/04/2016.
//  Copyright © 2016 Appitized. All rights reserved.
//

import UIKit
import MobileCoreServices
import Photos
import UserNotifications
import AVFoundation

class DashboardViewController: UIViewController {
    
    static let sharedInstance = DashboardViewController()
    static let timescale: CMTimeScale = 1000
    
    @IBOutlet weak var previewView: PreviewView!
    @IBOutlet weak var promptLabel: UILabel!
    @IBOutlet weak var incidentRecordingLabel: UILabel!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var recordingIndicatorView: UIView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordLabel: UILabel!
    
    @IBOutlet weak var subscriptionView: UIView!
    @IBOutlet weak var subscriptionButton: UIButton!
    
    @IBOutlet weak var accDetectionPopup: UIView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    
    @IBOutlet weak var tintView: UIView!
    
    let alertDuration = 10.0
    let durationAfterDetection = CMTimeMakeWithSeconds(5, timescale)
    let sessionQueue = DispatchQueue(label: "session queue")
    let reportWorkflowSegue = "reportWorkflowSegue"
    var manual_report : Bool = false
    var isAccident : Bool = false
    var wasRecording:Bool = false

    static var crashDetectedTimestamp: Date = Date()
    
    var player: AVAudioPlayer?
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
    
    override var shouldAutorotate: Bool {
        if let recording = VideoManager.sharedInstance.movieFileOutput?.isRecording {
            return !recording
        } else {
            return true
        }
    }
    
    public func removePreviewLayer() {
        self.previewView.removeFromSuperview()
        self.previewView = nil
    }
    
    var recordingIndicatorTimer : Timer?
    var isRecordingIncident = false
    
    let kShownVideo = "shownVideo"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("viewDidLoad")
        
        NotificationCenter.default.addObserver(self, selector: #selector(DashboardViewController.didBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(DashboardViewController.didEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: self, action:  #selector (self.touchEventHandler (_:)))
        self.previewView.addGestureRecognizer(tapGesture)
        
        IncidentDetector.sharedInstance.incidentClosure = {
            [weak self] in
            DispatchQueue.main.async(execute: {
                if let weakSelf = self {
                    weakSelf.reportIncident()
                }
            })
        }
        
    }
    
    func touchEventHandler(_ sender:UITapGestureRecognizer){
        print("touchEventHandler")
        print(UIScreen.main.brightness)
        if UIScreen.main.brightness < 0.5 {
            UIScreen.main.brightness = 0.5
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(15 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                if let movieFileOutput = VideoManager.sharedInstance.movieFileOutput {
                    if movieFileOutput.isRecording && !self.isRecordingIncident {
                        UIScreen.main.brightness = 0.1
                    }
                }
            })
        }
    }
    
    func didBecomeActive() {
        print("didBecomeActive")
        if wasRecording {
            wasRecording = false
            resume()
        }
    }
    
    func didEnterBackground() {
        print("didEnterBackground")
        
        if let movieFileOutput = VideoManager.sharedInstance.movieFileOutput {
            if movieFileOutput.isRecording {
                wasRecording = true
                if Shared.shared.isGrantedNotificationAccess{
                    //add notification code here
                    
                    //Set the content of the notification
                    if #available(iOS 10.0, *) {
                        let content = UNMutableNotificationContent()
                        content.title = "Alert!"
                        content.body = "4Sight is no longer recording. Please reenter the app to continue recording."
                        content.sound = UNNotificationSound.default()
                        
                        //Set the trigger of the notification -- here a timer.
                        let trigger = UNTimeIntervalNotificationTrigger(
                            timeInterval: 1.0,
                            repeats: false)
                        
                        //Set the request for the notification from the above
                        let request = UNNotificationRequest(
                            identifier: "background.message",
                            content: content,
                            trigger: trigger
                        )
                        
                        //Add the notification to the currnet notification center
                        UNUserNotificationCenter.current().add(
                            request, withCompletionHandler: nil)
                    }
                    else {
                        
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        
        UIScreen.main.brightness = 0.5
        
        super.viewWillAppear(animated)
        
        reportButton.layer.cornerRadius = 10
        reportButton.layer.masksToBounds = true
        reportButton.layer.borderColor = UIColor.orange.cgColor
        reportButton.layer.borderWidth = 3
        
        recordingIndicatorView.alpha = 0
        recordingIndicatorView.layer.cornerRadius = 15
        recordingIndicatorView.layer.masksToBounds = true
        
        recordButton.layer.cornerRadius = 33
        recordButton.layer.masksToBounds = true
        recordButton.isEnabled = true
        reportButton.isEnabled = true
        
        recordLabel.layer.cornerRadius = 28
        recordLabel.layer.masksToBounds = true
        
        /*  2016-10-3 by Alex */
        subscriptionButton.layer.cornerRadius = 10
        subscriptionButton.layer.masksToBounds = true
        subscriptionButton.layer.borderColor = UIColor.black.cgColor
        subscriptionButton.layer.borderWidth = 3
        
        subscriptionView.layer.cornerRadius = 5
        
        accDetectionPopup.layer.cornerRadius = 12
        accDetectionPopup.layer.borderColor = UIColor.orange.cgColor
        accDetectionPopup.layer.borderWidth = 6
        
        cancelButton.layer.cornerRadius = 8
        cancelButton.layer.masksToBounds = true
        cancelButton.layer.borderColor = UIColor(red: 1.0, green: 51.0/255, blue: 0, alpha: 1.0).cgColor
        cancelButton.layer.backgroundColor = UIColor(red: 1.0, green: 85.0/255, blue: 16.0/255, alpha: 1.0).cgColor
        cancelButton.layer.borderWidth = 3
        
        continueButton.layer.cornerRadius = 8
        continueButton.layer.masksToBounds = true
        continueButton.layer.borderColor = UIColor(red: 0, green: 190.0/255, blue: 13.0/255, alpha: 1.0).cgColor
        continueButton.layer.backgroundColor = UIColor(red: 126.0/255, green: 211.0/255, blue: 33.0/255, alpha: 1.0).cgColor
        continueButton.layer.borderWidth = 3
        
        tintView.isHidden = true
        subscriptionView.isHidden = true
        
//        IAPProducts.store.requestProducts{_,_ in 
//            
//        }
        
        manual_report = false
        /* ----------------------- */
        
        previewView.session = VideoManager.sharedInstance.captureSession
        
        //VideoManager.sharedInstance.checkAVAuthStatus()
        VideoManager.sharedInstance.setupCaptureSession()
        
        VideoManager.sharedInstance.updateOrientationCallback = {
            [weak self] in
            DispatchQueue.main.async(execute: {
                if let weakSelf = self {
                    let statusBarOrientation = UIApplication.shared.statusBarOrientation
                    weakSelf.previewView.previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.mappedfromUIInterfaceOrientation(statusBarOrientation)
                }
            })
        }
        
        VideoManager.sharedInstance.recordingStateBegunCallback = {
            [weak self] in
            
            DispatchQueue.main.async(execute: {
                if let weakSelf = self {
                    IncidentDetector.sharedInstance.start()
                    weakSelf.updateUIForRecording(true)
                }
            })
            /* 2016-10-17 by Alex */
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(15 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                if let weakSelf = self, let movieFileOutput = VideoManager.sharedInstance.movieFileOutput {
                    if movieFileOutput.isRecording && !weakSelf.isRecordingIncident {
                        UIScreen.main.brightness = 0.1
                    }
                }
            })
        }
        
        VideoManager.sharedInstance.recordingStateEndedCallback = {
            [weak self] (videoOutputURL, withError) in
            UIScreen.main.brightness = 0.5 // 2016-10-15 by Alex
            DispatchQueue.main.async(execute: {
                if let weakSelf = self {
                    weakSelf.processRecordedVideo(videoOutputURL: videoOutputURL as URL, error: withError)
                }
            })
        }
        
        if !VideoManager.sharedInstance.captureSession.isRunning {
            VideoManager.sharedInstance.startSession {
                [weak self] (success) in
                
                DispatchQueue.main.async(execute: {
                    
                    if let weakSelf = self {
                        if (success) {
                            weakSelf.recordButton.isEnabled = true
                            weakSelf.reportButton.isEnabled = true
                        } else {
                            var alertController: UIAlertController
                            
                            if (VideoManager.sharedInstance.authorized) {
                                alertController = UIAlertController(title: "Unable to record Video", message: "Capture Session configuration failed: \(VideoManager.sharedInstance.errorStrings.first)", preferredStyle: .alert)
                            } else {
                                alertController = UIAlertController(title: "Unable to record Video", message: "Unauthorized", preferredStyle: .alert)
                            }
                            
                            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                            weakSelf.present(alertController, animated: true, completion:nil)
                        }
                    }
                })
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        previewView.frame = view.frame
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("viewDidDisappear")
        VideoManager.sharedInstance.sessionQueue.async {
            if VideoManager.sharedInstance.setupSucceeded {
                VideoManager.sharedInstance.captureSession.stopRunning()
            }
        }
        VideoManager.sharedInstance.captureSession.removeInput(VideoManager.sharedInstance.videoDeviceInput)
        VideoManager.sharedInstance.captureSession.removeOutput(VideoManager.sharedInstance.movieFileOutput)
        VideoManager.sharedInstance.captureSession.removeInput(VideoManager.sharedInstance.audioDeviceInput)
    }
    
    func processRecordedVideo(videoOutputURL: URL, error:Error!) {
        
        IncidentDetector.sharedInstance.stop()
        
        debugPrint("Did finish recording to file: \(videoOutputURL.absoluteString)")
        
        let cleanup = VideoManager.sharedInstance.cleanupBlock(url: videoOutputURL)
        
        if let error = error {
            debugPrint("Error capturing output: \(String(describing: error))") //TODO: Check this
            cleanup()
        } else if isRecordingIncident {
            saveVideoToCameraRoll(url: videoOutputURL) {
                self.uploadVideo(url: videoOutputURL, cleanup: cleanup)
            }
        } else {
            cleanup()
        }
     
        UIApplication.shared.isIdleTimerDisabled = true
        self.updateUIForRecording(false)
        
        if isRecordingIncident {
            isRecordingIncident = false
            self.showAccidentAlert()
        }
    }
    
    func saveVideoToCameraRoll(url: URL, completion: @escaping ()->()) {
        
        PHPhotoLibrary.requestAuthorization({
            (status:PHAuthorizationStatus) in
            
            guard status == PHAuthorizationStatus.authorized else {
                debugPrint("Could not save video to photo library - Unauthorized")
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                
                let options = PHAssetResourceCreationOptions()
                options.shouldMoveFile = false
                
                let changeRequest = PHAssetCreationRequest.forAsset()
                changeRequest.addResource(with: PHAssetResourceType.video, fileURL: url, options: options)
                
                }, completionHandler: {
                    (success, error) in
                    
                    if !success {
                        debugPrint("Could not save video to photo library: \(error?.localizedDescription)")
                    } else {
                        debugPrint("Successfully saved video!")
                    }
                    completion()
            })
        })
    }
    
    func uploadVideo(url: URL, cleanup: @escaping ()->()) {
        
        VideoManager.sharedInstance.processVideo(url: url, completion: {
            (url, error) in
            
            if let error = error {
                debugPrint("Error processing video: \(error.localizedDescription)")
            } else if let url = url, let videoData = try? Data(contentsOf: url) {
                
                IncidentService.sharedInstance.currentIncident.videoData = videoData
                
                MediaService.createVideo(completion: {
                    (error) in
                    
                    if let error = error {
                        debugPrint(error)
                    } else {
                        
                        MediaService.uploadVideo(completion: {
                            (error) in
                            
                            if let error = error {
                                debugPrint(error)
                                // TODO: Store video to upload later!
                            } else {
                                debugPrint("Video Uploaded!")
                            }
                        })
                    }
                    cleanup()
                })
            }
        })
    }
    
    func updateUIForRecording(_ recording:Bool) {
        
        if (recording) {
            recordingIndicatorView.alpha = 0
            recordingIndicatorView.isHidden = false
            recordingIndicatorTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(DashboardViewController.animateRecordingIndicator), userInfo: nil, repeats: true)
            infoButton.isHidden = true
            profileButton.isHidden = true
            recordButton.isEnabled = true
            reportButton.isEnabled = true
            recordLabel.text = "STOP"
            recordLabel.textColor = UIColor.white
            recordLabel.backgroundColor = UIColor.red
            promptLabel.isHidden = true
            //reportButton.isHidden = true
        } else {
            recordingIndicatorView.isHidden = true
            recordingIndicatorTimer?.invalidate()
            infoButton.isHidden = false
            profileButton.isHidden = false
            recordButton.isEnabled = true
            reportButton.isEnabled = true
            recordLabel.text = "REC"
            recordLabel.textColor = UIColor.darkGray
            recordLabel.backgroundColor = UIColor.white
            promptLabel.isHidden = false
            incidentRecordingLabel.isHidden = true
//            reportButton.isHidden = false
        }
    }
    
    
    func animateRecordingIndicator() {
        if recordingIndicatorView.alpha > 0.5 {
            UIView.animate(withDuration: 1, animations: {
                self.recordingIndicatorView.alpha = 0
            })
        } else {
            UIView.animate(withDuration: 1, animations: {
                self.recordingIndicatorView.alpha = 1
            })
        }
    }
    
    @IBAction func reportButtonPressed(_ sender: AnyObject) {
        
            if !isRecordingIncident {
//                if IAPProducts.store.isProductPurchased(IAPProducts.monthlySubscription) {
                self.manual_report = true

                if !(VideoManager.sharedInstance.movieFileOutput?.isRecording ?? true) {
                    IncidentService.sharedInstance.currentIncident.videoID = ""
                    recordButtonPressed(sender)
                
                    self.incidentRecordingLabel.isHidden = false
                    self.promptLabel.isHidden = true
                }
                
                reportIncident()

//                } else {
//                    self.tintView.isHidden = false
//                    self.subscriptionView.isHidden = false
//                }
            }
    }

    func reportIncident() {

        if isRecordingIncident {
            return
        }
        
        UIScreen.main.brightness = 1.0 // 2016-10-15 by Alex
        
        DashboardViewController.crashDetectedTimestamp = Date()
        
        self.incidentRecordingLabel.isHidden = false
        isRecordingIncident = true
        debugPrint("Incident Detected!")
        
        sessionQueue.asyncAfter(deadline: DispatchTime.now() + Double(Int64(durationAfterDetection.seconds) * Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC), execute: {
                debugPrint("Stopping Recording Incident...")
                VideoManager.sharedInstance.stopRecording()
        })
    }
    
    func playAccidentSound() {
        let url = Bundle.main.url(forResource: "Accident Alert_V3", withExtension: "mp3")!
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            
            player.prepareToPlay()
            player.play()
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    func showAccidentAlert() {
        if manual_report { // 2016-10-12 by Alex
            manual_report = false
            self.performSegue(withIdentifier: self.reportWorkflowSegue, sender: self)
        }
        else {
            accDetectionPopup.isHidden = false
            tintView.isHidden = false
            playAccidentSound()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(self.alertDuration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                if !self.isAccident {
                    
                    if !self.accDetectionPopup.isHidden {
                        self.resume()
                    }
                    
                    self.accDetectionPopup.isHidden = true
                    self.tintView.isHidden = true
                    UIScreen.main.brightness = 0.1

                }else{
                    self.isAccident = false
                }
            })
        }
        
        /*
        let alert = UIAlertController(title: "Crash Detected!", message: "A crash has been detected. The video recording has been saved and uploaded. Tap Report Accident below to record details of the accident.", preferredStyle: .alert)
        
        let confirm = UIAlertAction(title: "Report Accident", style: .default) {(_) in
            DispatchQueue.main.asyncAfter(deadline:  DispatchTime.now(), execute: {
                self.performSegue(withIdentifier: self.reportWorkflowSegue, sender: self)
            })
        }
        
        let cancel = UIAlertAction(title: "No", style: .cancel) { (_) in
            self.resume()
        }
        
        alert.addAction(confirm)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: { [weak self] in
            
            if let weakSelf = self {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(weakSelf.alertDuration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                    alert.dismiss(animated: true, completion: nil)
                    weakSelf.resume()
                })
            }
        })
        */
    }
    
    @IBAction func cancelButtonPressed(_ sender: AnyObject) {
        
        isAccident = false
        
        accDetectionPopup.isHidden = true
        tintView.isHidden = true
        
        self.resume()
    }
    
    @IBAction func continueButtonPressed(_ sender: AnyObject) {
        isAccident = true
        
        accDetectionPopup.isHidden = true
        tintView.isHidden = true
        
        DispatchQueue.main.asyncAfter(deadline:  DispatchTime.now(), execute: {
            self.performSegue(withIdentifier: self.reportWorkflowSegue, sender: self)
        })
    }
    
    @IBAction func infoButtonPressed(_ sender: AnyObject) {
        //performSegue(withIdentifier: "showInfoVideo", sender: self)
        performSegue(withIdentifier: "showInfoScreen", sender: self) //2016-10-4 by Alex
    }
    
    @IBAction func recordButtonPressed(_ sender: AnyObject) {
        
        recordButton.isEnabled = false
        reportButton.isEnabled = true

        if let movieFileOutput = VideoManager.sharedInstance.movieFileOutput {
            if !movieFileOutput.isRecording {
//                if IAPProducts.store.isProductPurchased(IAPProducts.monthlySubscription) {
                    IncidentService.sharedInstance.currentIncident.videoID = ""
                    
                    VideoManager.sharedInstance.startRecording {
                        let connection = movieFileOutput.connection(withMediaType: AVMediaTypeVideo)
                        connection?.videoOrientation = self.previewView.previewLayer!.connection.videoOrientation
                    }
//                } else {
//                    self.tintView.isHidden = false
//                    self.subscriptionView.isHidden = false
//                }
            } else {
                if (!isRecordingIncident) {
                    VideoManager.sharedInstance.stopRecording()
                    UIScreen.main.brightness = 0.5
                }
            }
        }
    }
    
    @IBAction func exitSubscriptionPopup() {
        
        self.subscriptionView.isHidden = true
        self.tintView.isHidden = true
        recordButton.isEnabled = true
        reportButton.isEnabled = true
    }
    
    func resume() {
        recordButton.isEnabled = true
        reportButton.isEnabled = true
        
        VideoManager.sharedInstance.startRecording(){
            if let movieFileOutput = VideoManager.sharedInstance.movieFileOutput {
                
                let connection = movieFileOutput.connection(withMediaType: AVMediaTypeVideo)
                connection?.videoOrientation = self.previewView.previewLayer!.connection.videoOrientation
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "showInfoVideo" {
//  2016-10-4 by Alex
//            if let videoPlayerVC = segue.destination as? VideoPlayerViewController {
//                
//                videoPlayerVC.videoURL = Bundle.main.url(forResource: "concept", withExtension: "mp4")!
//                videoPlayerVC.callback = { [weak self] in
//                    if let weakSelf = self {
//                        weakSelf.dismiss(animated: true, completion: nil)
//                    }
//                }
//            }
        }
        else if segue.identifier == "showInfoScreen" {
            let tutorialPageVC = TutorialPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
            tutorialPageVC.exit = {
                [weak self] in
                if let weakSelf = self {
                    weakSelf.dismiss(animated: true, completion: nil)
                }
            }
            present(tutorialPageVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func unwindToDashboard(segue: UIStoryboardSegue) {
    
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let deviceOrientation = UIDevice.current.orientation
        if UIDeviceOrientationIsPortrait(deviceOrientation) || UIDeviceOrientationIsLandscape(deviceOrientation) {
            self.previewView.previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.mappedfromUIDeviceOrientation(deviceOrientation)
        }
    }
}
