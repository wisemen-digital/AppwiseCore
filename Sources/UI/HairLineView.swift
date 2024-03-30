//
// AppwiseCore
// Copyright © 2024 Wisemen
//

import IBAnimatable

open class HairLineView: AnimatableView {
	override open var intrinsicContentSize: CGSize {
		let pixel: CGFloat = 1 / UIScreen.main.scale
		return CGSize(width: pixel, height: pixel)
	}
}
