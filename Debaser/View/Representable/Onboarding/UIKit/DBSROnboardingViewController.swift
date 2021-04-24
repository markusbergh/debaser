//
//  DBSROnboardingViewController.swift
//  Debaser
//
//  Created by Markus Bergh on 2018-01-25.
//  Copyright © 2018 Markus Bergh. All rights reserved.
//

import UIKit

class DBSROnboardingViewController: UIViewController {
    
    private static let storyboardName = "Onboarding"

    // MARK: Private
    
    private lazy var pageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    private lazy var pageControl = UIPageControl(frame: .zero)
    private lazy var skipButton = UIButton()
    
    @IBOutlet private var debaserLogotypeTopConstraint: NSLayoutConstraint! {
        didSet {
            /*
            if UIDevice.current.screenType == .iPhone5 {
                debaserLogotypeTopConstraint.constant = 10.0
            }
            */
        }
    }
    @IBOutlet private var debaserLogotype: UIImageView! {
        didSet {
            /*
            if UIDevice.current.screenType == .iPhone5 {
                debaserLogotype.widthAnchor.constraint(equalToConstant: 100).isActive = true
            }
            */
        }
    }
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [newPageViewController(page: "Page1"),
                newPageViewController(page: "Page2"),
                newPageViewController(page: "Page3"),
                newPageViewController(page: "Page4")]
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //view.backgroundColor = UIColor.onboardingBackground
        
        // Add custom page controller
        setupPageControl()

        // Add skip button
        setupSkipButton()

        view.bringSubviewToFront(debaserLogotype)
    }
    
    private func setupPageControl() {
        pageController.dataSource = self
        pageController.delegate = self
        
        addChild(pageController)
        view.addSubview((pageController.view)!)
        pageController.didMove(toParent: self)

        if let firstViewController = orderedViewControllers.first {
            pageController.setViewControllers([firstViewController],
                                              direction: .forward,
                                              animated: true,
                                              completion: nil)
        }
//
//        // Add custom page control
//        pageControl.currentPage = 0
//        pageControl.numberOfPages = orderedViewControllers.count
//        //pageControl.pageIndicatorTintColor = UIColor.DBSRPalette.onboardingPageControlColor
//        //pageControl.currentPageIndicatorTintColor = UIColor.DBSRPalette.onboardingPageControlActiveColor
//        pageControl.translatesAutoresizingMaskIntoConstraints = false
//        pageControl.isUserInteractionEnabled = false
//        view.addSubview(pageControl)
//
////        var pageControlHeightAnchorConstant: CGFloat
////        switch UIDevice.current.screenType {
////        case .iPhone6:
////            pageControlHeightAnchorConstant = 75
////        default:
////            pageControlHeightAnchorConstant = 100
////        }
////
////        NSLayoutConstraint.activate([
////            pageControl.widthAnchor.constraint(equalToConstant: view.frame.size.width),
////            pageControl.heightAnchor.constraint(equalToConstant: pageControlHeightAnchorConstant),
////            pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor),
////        ])
    }
    
    private func setupSkipButton() {
        /*
        skipButton.setTitle("Hoppa över", for: .normal)
        skipButton.setTitleColor(UIColor.DBSRPalette.onboardingSkipButtonTextColor, for: .normal)
        skipButton.setTitleColor(UIColor.DBSRPalette.onboardingSkipButtonHighlightColor, for: .highlighted)
        skipButton.titleLabel?.font = UIFont(name: "Avenir-Heavy", size: 16)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        skipButton.addTarget(self, action: #selector(dismissOnboarding), for: .touchUpInside)
        view.addSubview(skipButton)
        
        NSLayoutConstraint.activate([
            skipButton.widthAnchor.constraint(lessThanOrEqualToConstant: view.frame.size.width / 2),
            skipButton.centerYAnchor.constraint(equalTo: pageControl.centerYAnchor),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            ])
        */
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let firstStepViewController = pageController.viewControllers?.first as? DBSROnboardingStepViewController else { return }
        
        if var screenShotFrame = firstStepViewController.screenShot?.frame {
            screenShotFrame.origin.y -= 20
            
            UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut, animations: {
                firstStepViewController.screenShot?.alpha = 1.0
                firstStepViewController.screenShot?.frame = screenShotFrame
            })
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func newPageViewController(page: String) -> UIViewController {
        return UIStoryboard(name: DBSROnboardingViewController.storyboardName, bundle: nil).instantiateViewController(withIdentifier: "\(page)ViewController")
    }
}

// MARK: - UIPageViewControllerDataSource

extension DBSROnboardingViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else { return nil }
        guard orderedViewControllers.count > previousIndex else { return nil }
        
        guard let stepViewController = orderedViewControllers[previousIndex] as? DBSROnboardingStepViewController else {
            return nil
        }
        
        stepViewController.pageIndex = previousIndex
        
        return stepViewController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex, orderedViewControllersCount > nextIndex else { return nil }
        
        guard let stepViewController = orderedViewControllers[nextIndex] as? DBSROnboardingStepViewController else {
            return nil
        }
        
        stepViewController.pageIndex = nextIndex
        
        return stepViewController
    }
}

// MARK: - UIPageViewControllerDelegate

extension DBSROnboardingViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let firstViewController = pageController.viewControllers?.first,
            let index = orderedViewControllers.firstIndex(of: firstViewController) {
            
            // Update page control index
            pageControl.currentPage = index
            
            if(index == orderedViewControllers.count - 1) {
                toggleVisibilitySkipButton(hide: true)
                
                return
            }
            
            toggleVisibilitySkipButton(hide: false)
        }
    }
}

// MARK: - Actions

extension DBSROnboardingViewController {
    
    func toggleVisibilitySkipButton(hide isHidden:Bool) {
        UIView.animate(withDuration: 0.3, animations: {
            self.skipButton.alpha = isHidden ? 0.0 : 1.0
        })
    }
    
    @objc func dismissOnboarding(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
