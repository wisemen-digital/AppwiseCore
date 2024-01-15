//
// AppwiseCore
// Copyright © 2023 Wisemen
//

import IBAnimatable
import UIKit

open class HairLineView: AnimatableView {
	override open var intrinsicContentSize: CGSize {
		let pixel: CGFloat = 1 / UIScreen.main.scale
		return CGSize(width: pixel, height: pixel)
	}
}
