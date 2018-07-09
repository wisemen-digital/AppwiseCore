//
//  Deprecations.swift
//  AppwiseCore
//
//  Created by David Jennes on 06/03/2017.
//  Copyright © 2018 Appwise. All rights reserved.
//

import CloudKit
import UIKit

#if !(swift(>=4.1.50) || (swift(>=3.4) && !swift(>=4.0)))
public extension UIApplication {
    typealias LaunchOptionsKey = UIApplicationLaunchOptionsKey
    typealias OpenURLOptionsKey = UIApplicationOpenURLOptionsKey
    typealias ExtensionPointIdentifier = UIApplicationExtensionPointIdentifier
}

@available(iOS 10.0, *)
public extension CKShare {
	typealias Metadata = CKShareMetadata
}

public typealias UIUserActivityRestoring = Any
#endif
