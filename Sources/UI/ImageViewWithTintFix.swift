//
// AppwiseCore
// Copyright © 2026 Wisemen
//

import UIKit

open class ImageViewWithTintFix: UIImageView {
	override open func awakeFromNib() {
		super.awakeFromNib()

		let tint = tintColor
		tintColor = #colorLiteral(red: 0.1, green: 0.2, blue: 0.3, alpha: 1)
		tintColor = tint
	}

    override open func layoutSubviews() {
		super.layoutSubviews()

		configureCornerRadius()
	}

    /// Corner radius (defaults to `.nan` which is "none"). Setting this to any number value will enable `maskToBounds`.
	@IBInspectable open var cornerRadius: CGFloat = CGFloat.nan {
		didSet { setNeedsLayout() }
	}

    /// Essentially sets the corner radius in such a way that the view appears circular. Setting this to true will enable `maskToBounds`.
	@IBInspectable var isCircular: Bool = false {
		didSet { setNeedsLayout() }
	}
}

private extension ImageViewWithTintFix {
	func configureCornerRadius() {
		let radius = isCircular
			? min(bounds.width, bounds.height) / 2
			: cornerRadius

		guard !radius.isNaN, radius > 0 else { return }
		layer.cornerRadius = radius
        layer.masksToBounds = true
	}
}
