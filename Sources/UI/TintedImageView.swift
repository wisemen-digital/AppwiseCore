//
//  TintedImageView.swift
//  AppwiseCore
//
//  Created by David Jennes on 15/11/2016.
//  Copyright © 2017 Appwise. All rights reserved.
//

import IBAnimatable

class TintedImageView: AnimatableImageView {
	override func awakeFromNib() {
		super.awakeFromNib()

		let t = tintColor
		tintColor = #colorLiteral(red: 0.1, green: 0.2, blue: 0.3, alpha: 1)
		tintColor = t
	}
}
