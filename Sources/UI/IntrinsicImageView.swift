//
// AppwiseCore
// Copyright © 2023 Wisemen
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

		if let image {
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
