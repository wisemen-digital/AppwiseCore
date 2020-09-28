//
//  IntrinsicImageView.swift
//  AppwiseCore
//
//  Created by David Jennes on 29/09/2020.
//  Copyright © 2020 Appwise. All rights reserved.
//

open class IntrinsicImageView: UIImageView {
	private weak var ratioConstraint: NSLayoutConstraint?

	override open var image: UIImage? {
		didSet {
			setNeedsUpdateConstraints()
		}
	}

	override open func updateConstraints() {
		if let constraint = ratioConstraint {
			NSLayoutConstraint.deactivate([constraint])
			ratioConstraint = nil
		}

		if let image = image {
			let ratio = image.size.width / image.size.height
			let constraint = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: self, attribute: .height, multiplier: ratio, constant: 0).then {
				$0.priority = UILayoutPriority(999)
				$0.identifier = "IntrinsicImageView Ratio \(image.size.width):\(image.size.height)"
			}

			addConstraint(constraint)
			ratioConstraint = constraint
		}

		super.updateConstraints()
	}
}
