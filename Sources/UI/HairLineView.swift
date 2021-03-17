//
// AppwiseCore
// Copyright © 2021 Appwise
//

import IBAnimatable

open class HairLineView: AnimatableView {
	override open var intrinsicContentSize: CGSize {
		let pixel: CGFloat = 1 / UIScreen.main.scale
		return CGSize(width: pixel, height: pixel)
	}
}
