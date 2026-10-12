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
}
