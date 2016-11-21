//
//  TutorialPageViewController.swift
//  4Sight
//

import UIKit
import AVFoundation

class TutorialPageViewController: UIPageViewController {
    
    var orderedViewControllers: [UIViewController]?
    var exit: (()->())?
    var player: AVAudioPlayer?
    var bottomView: UIView?
    var imageView:UIImageView?
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        setupTutorialViewControllers()
        self.setViewControllers([orderedViewControllers![0]], direction: .forward, animated: true, completion: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let screenSize: CGRect = UIScreen.main.bounds
        bottomView=UIView(frame: CGRect(x:0,y:screenSize.height*452/667,width:screenSize.width,height:screenSize.height*215/667))
        imageView = UIImageView(image: UIImage(named: "tutorial_1_bottom"))
        imageView?.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height*215/667)
        self.bottomView?.addSubview(imageView!)
        self.view.addSubview(self.bottomView!)
        
        playSound(index:1)
    }
    
    func playSound(index: Int) {
        var url : URL? = nil
        switch index {
        case 1:
            url = Bundle.main.url(forResource: "MP3_Help Screen 1_V3", withExtension: "mp3")!
            break
        case 2:
            url = Bundle.main.url(forResource: "MP3_Help Screen 2_V3", withExtension: "mp3")!
            break
        case 3:
            url = Bundle.main.url(forResource: "MP3_Help Screen 3_V3", withExtension: "mp3")!
            break
        case 4:
            url = Bundle.main.url(forResource: "MP3_Help Screen 4_V3", withExtension: "mp3")!
            break
        case 5:
            url = Bundle.main.url(forResource: "MP3_Help Screen 5_V3", withExtension: "mp3")!
            break
        case 6:
            url = Bundle.main.url(forResource: "MP3_Help Screen 6_V3", withExtension: "mp3")!
            break
        default: break
        }
        
        
        do {
            player = try AVAudioPlayer(contentsOf: url!)
            guard let player = player else { return }
            
            player.prepareToPlay()
            player.play()
        } catch let error as NSError {
            print(error.description)
        }
    }
    
    func setupTutorialViewControllers() {
        
        let tutorialVCs: [TutorialViewController] = [
            TutorialViewController(nibName: "TutorialViewController", bundle: nil),
            TutorialViewController(nibName: "TutorialViewController", bundle: nil),
            TutorialViewController(nibName: "TutorialViewController", bundle: nil),
            TutorialViewController(nibName: "TutorialViewController", bundle: nil),
            TutorialViewController(nibName: "TutorialViewController", bundle: nil),
            TutorialViewController(nibName: "TutorialViewController", bundle: nil)
        ]
        
        for (index, tutorialVC) in tutorialVCs.enumerated() {
            if let image = UIImage(named:"tutorial_\(index+1)") {
                tutorialVC.image = image
            }
            
            if index == tutorialVCs.count - 1 {
                tutorialVC.exit = { [weak self] in
                    if let weakSelf = self {
                        weakSelf.exit?()
                    }
                }
            }
        }
        
        orderedViewControllers = tutorialVCs
    }
}

extension TutorialPageViewController: UIPageViewControllerDataSource {
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        print("before")
        let currentIndex = orderedViewControllers!.index(of: viewController)
        
        imageView?.image = UIImage(named: "tutorial_\(currentIndex!+1)_bottom")
        playSound(index: currentIndex!+1)
        
        guard currentIndex! > 0 else {
            return nil
        }
        
        
        return orderedViewControllers![currentIndex!-1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        print("after")
        let currentIndex = orderedViewControllers!.index(of: viewController)
        
        imageView?.image = UIImage(named: "tutorial_\(currentIndex!+1)_bottom")
        playSound(index: currentIndex!+1)
        
        guard currentIndex! < orderedViewControllers!.count - 1 else {
            return nil
        }
        
        return orderedViewControllers![currentIndex!+1]
    }
}
