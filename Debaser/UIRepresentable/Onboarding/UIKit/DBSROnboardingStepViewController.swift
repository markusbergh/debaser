//
//  DBSROnboardingStepViewController.swift
//  Debaser
//
//  Created by Markus Bergh on 2018-01-25.
//  Copyright © 2018 Markus Bergh. All rights reserved.
//

import UIKit

class DBSROnboardingStepViewController: UIViewController {

    // MARK: Public
    @IBOutlet var screenShot: UIImageView!
    
    var pageIndex = 0
    var isAnimated = false
    var hasAppeared = false
    
    // MARK: Private
    
    @IBOutlet private var closeButton: DBSROnboardingCloseButton!
    @IBOutlet private var spotifyLogo: UIImageView!
    @IBOutlet private var spotifyInfoText: UILabel!
    @IBOutlet private var spotifyButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Reset for last step
        spotifyLogo?.alpha = 0.0
        spotifyLogo?.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        spotifyInfoText?.alpha = 0.0
        spotifyInfoText?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        spotifyButton?.alpha = 0.0
        spotifyButton?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        closeButton?.alpha = 0.0
        closeButton?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let screenShot = self.screenShot else { return }
        
        if pageIndex > 0, !isAnimated {
            var screenShotFrame = screenShot.frame
            screenShotFrame.origin.y -= 20

            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                self?.screenShot.alpha = 1.0
                self?.screenShot.frame = screenShotFrame

                self?.isAnimated = true
                }, completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Last step animations
        UIView.animate(withDuration: 0.4, delay: 0.1, options: .curveEaseOut, animations: { [weak self] in
            self?.spotifyLogo?.alpha = 1.0
            self?.spotifyLogo?.transform = .identity
            }, completion: nil)
        
        UIView.animate(withDuration: 0.4, delay: 0.3, options: .curveEaseOut, animations: { [weak self] in
            self?.spotifyButton?.alpha = 1.0
            self?.spotifyButton?.transform = .identity
            }, completion: nil)
        
        UIView.animate(withDuration: 0.4, delay: 0.3, options: .curveEaseOut, animations: { [weak self] in
            self?.spotifyInfoText?.alpha = 1.0
            self?.spotifyInfoText?.transform = .identity
            }, completion: nil)
        
        UIView.animate(withDuration: 0.4, delay: 0.5, options: .curveEaseOut, animations: { [weak self] in
            self?.closeButton?.alpha = 1.0
            self?.closeButton?.transform = .identity
            }, completion: nil)
    }
    
    @IBAction func closeOnboarding(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func showSpotifySettings(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        
        /*

        guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
        guard let tabBarController = delegate.window?.rootViewController as? DBSRTabBarController else { return }
        
        // Go to settings tab
        tabBarController.selectedIndex = 3
        
        // Perform segue on settings
        if let settingsNavigationController = tabBarController.viewControllers?.last as? UINavigationController,
            let settingsViewController = settingsNavigationController.viewControllers[0] as? DBSRSettingsViewController {
            settingsViewController.performSegue(withIdentifier: "spotifySegue", sender: nil)
        }
 
        */
    }
}
