//
// AppwiseCore
// Copyright © 2026 Wisemen
//

import UIKit

open class HairLineView: UIView {
	override open var intrinsicContentSize: CGSize {
		let pixel: CGFloat = 1 / UIScreen.main.scale
		return CGSize(width: pixel, height: pixel)
	}
}
