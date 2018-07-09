//
//  Deprecations.swift
//  AppwiseCore
//
//  Created by David Jennes on 06/03/2017.
//  Copyright © 2018 Appwise. All rights reserved.
//

import UIKit

#if !(swift(>=4.1.50) || (swift(>=3.4) && !swift(>=4.0)))
extension UIViewController {
    var isMovingFromParent: Bool {
    	return isMovingFromParentViewController
    }
}
#endif
