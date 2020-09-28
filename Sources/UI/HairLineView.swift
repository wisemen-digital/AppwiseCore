//
//  HairLineView.swift
//  AppwiseCore
//
//  Created by David Jennes on 29/09/2020.
//  Copyright © 2020 Appwise. All rights reserved.
//

import IBAnimatable

open class HairLineView: AnimatableView {
	override open var intrinsicContentSize: CGSize {
		let pixel: CGFloat = 1 / UIScreen.main.scale
		return CGSize(width: pixel, height: pixel)
	}
}
