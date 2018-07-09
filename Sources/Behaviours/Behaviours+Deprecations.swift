//
//  Deprecations.swift
//  AppwiseCore
//
//  Created by David Jennes on 06/03/2017.
//  Copyright © 2018 Appwise. All rights reserved.
//

import UIKit

#if !(swift(>=4.1.50) || (swift(>=3.4) && !swift(>=4.0)))
extension UIApplication {
    static let willEnterForegroundNotification = NSNotification.Name.UIApplicationWillEnterForeground
    static let willResignActiveNotification = NSNotification.Name.UIApplicationWillResignActive
}

extension UIViewController {
    func addChild(_ vc: UIViewController) {
    	addChildViewController(vc)
    }

    func didMove(toParent vc: UIViewController) {
    	didMove(toParentViewController: vc)
    }
}
#endif
