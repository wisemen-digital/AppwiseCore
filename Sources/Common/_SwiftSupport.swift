//
//  SwiftSupport.swift
//  AppwiseCore
//
//  Created by David Jennes on 06/03/2017.
//  Copyright © 2019 Appwise. All rights reserved.
//

import CloudKit
import UIKit

#if !(swift(>=4.2))
public extension UIApplication {
    typealias LaunchOptionsKey = UIApplicationLaunchOptionsKey
    typealias OpenURLOptionsKey = UIApplicationOpenURLOptionsKey
    typealias ExtensionPointIdentifier = UIApplicationExtensionPointIdentifier

    static let willEnterForegroundNotification = NSNotification.Name.UIApplicationWillEnterForeground
    static let willResignActiveNotification = NSNotification.Name.UIApplicationWillResignActive
}

@available(iOS 10.0, *)
public extension CKShare {
	typealias Metadata = CKShareMetadata
}

public typealias UIUserActivityRestoring = Any

public extension UICollectionView {
	static let elementKindSectionFooter = UICollectionElementKindSectionFooter
	static let elementKindSectionHeader = UICollectionElementKindSectionHeader
}

public extension UISplitViewController {
	typealias DisplayMode = UISplitViewControllerDisplayMode
}

public extension UITableViewCell {
	typealias EditingStyle = UITableViewCellEditingStyle
}

public extension UIViewController {
    func addChild(_ vc: UIViewController) {
    	addChildViewController(vc)
    }

    func didMove(toParent vc: UIViewController) {
    	didMove(toParentViewController: vc)
    }

    var isMovingFromParent: Bool {
    	return isMovingFromParentViewController
    }
}
#endif
