//
// AppwiseCore
// Copyright © 2026 Wisemen
//

import UIKit

public extension UIInterfaceOrientationMask {
	private static let orientationMaskMapping: [String: UIInterfaceOrientationMask] = [
		"UIInterfaceOrientationPortrait": .portrait,
		"UIInterfaceOrientationPortraitUpsideDown": .portraitUpsideDown,
		"UIInterfaceOrientationLandscapeLeft": .landscapeLeft,
		"UIInterfaceOrientationLandscapeRight": .landscapeRight
	]

	static let orientationsFromInfoPlist: Self = {
		// iPad uses a separate key if present
		let key = UIDevice.current.userInterfaceIdiom == .pad
			? "UISupportedInterfaceOrientations~ipad"
			: "UISupportedInterfaceOrientations"

		let orientations = Bundle.main.infoDictionary?[key] as? [String] ?? []
		return orientations.reduce(Self()) { $0.union(orientationMaskMapping[$1] ?? []) }
	}()
}
