//
// AppwiseCore
// Copyright © 2026 Wisemen
//

import IBAnimatable

open class TintedImageView: AnimatableImageView {
	override open func awakeFromNib() {
		super.awakeFromNib()

		let tint = tintColor
		tintColor = #colorLiteral(red: 0.1, green: 0.2, blue: 0.3, alpha: 1)
		tintColor = tint
	}
}
