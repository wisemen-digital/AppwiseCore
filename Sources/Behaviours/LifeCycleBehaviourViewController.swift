//
// AppwiseCore
// Copyright © 2021 Appwise
//

import UIKit

final class LifecycleBehaviourViewController: UIViewController {
	private let behaviours: [ViewControllerLifeCycleBehaviour]

	init(behaviours: [ViewControllerLifeCycleBehaviour]) {
		self.behaviours = behaviours
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		fatalError("init(nibName:bundle:) has not been implemented")
	}

	@available(*, unavailable)
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		view.isHidden = true

		applyBehaviours { behaviour, viewController in
			behaviour.afterLoading(viewController: viewController)
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		applyBehaviours { behaviour, viewController in
			behaviour.beforeAppearing(viewController: viewController, animated: animated)
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)

		applyBehaviours { behaviour, viewController in
			behaviour.afterAppearing(viewController: viewController, animated: animated)
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)

		applyBehaviours { behaviour, viewController in
			behaviour.beforeDisappearing(viewController: viewController, animated: animated)
		}
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)

		applyBehaviours { behaviour, viewController in
			behaviour.afterDisappearing(viewController: viewController, animated: animated)
		}
	}

	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()

		applyBehaviours { behaviour, viewController in
			behaviour.beforeLayingOutSubviews(viewController: viewController)
		}
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		applyBehaviours { behaviour, viewController in
			behaviour.afterLayingOutSubviews(viewController: viewController)
		}
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)

		applyBehaviours { behaviour, viewController in
			behaviour.beforeTransitioning(viewController: viewController, to: size, with: coordinator)
		}

		coordinator.animate(alongsideTransition: { [weak self] _ in
			self?.applyBehaviours { behaviour, viewController in
				behaviour.whileTransitioning(viewController: viewController, to: size, with: coordinator)
			}
		}, completion: { [weak self] _ in
			self?.applyBehaviours { behaviour, viewController in
				behaviour.afterTransitioning(viewController: viewController, to: size, with: coordinator)
			}
		})
	}

	private func applyBehaviours(_ apply: (ViewControllerLifeCycleBehaviour, UIViewController) -> Void) {
		guard let parent = parent else { return }

		for behaviour in behaviours {
			apply(behaviour, parent)
		}
	}
}
