//
//  InspectableView.swift
//  AppwiseCore
//
//  Created by David Jennes on 29/12/2016.
//  Copyright © 2016 Appwise. All rights reserved.
//

import UIKit

public extension UIView {
	@IBInspectable var cornerRadius: CGFloat {
		get {
			return layer.cornerRadius
		}
		set {
			layer.cornerRadius = newValue
			layer.masksToBounds = newValue > 0
		}
	}

	@IBInspectable var borderWidth: CGFloat {
		get {
			return layer.borderWidth
		}
		set {
			layer.borderWidth = newValue
		}
	}

	@IBInspectable var borderColor: UIColor? {
		get {
			if let color = layer.borderColor {
				return UIColor(cgColor: color)
			} else {
				return nil
			}
		}
		set {
			layer.borderColor = newValue?.cgColor
		}
	}
}
