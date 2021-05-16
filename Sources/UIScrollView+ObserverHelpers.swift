//
//  UIScrollView+ObserverHelpers.swift
//  Demo
//
//  Created by Andreas Verhoeven on 16/05/2021.
//

import UIKit
import ObjectiveC.runtime

extension UIScrollView {
	/// Observes content offset changes by calling the callback when the content offset changes.
	///
	/// **Warning**: don't accidentally retain this scroll view in the callback, otherwise you have a retain cycle.
	///
	/// - Parameters:
	///		- callback: the callback to call when the content offset changes
	///
	///	- Returns: a `ScrollViewObserverCancellable` that can be used to stop observing.
	@discardableResult public func observeContentOffsetChanges(_ callback: @escaping () -> Void) -> ScrollViewObserverCancellable {
		let observer = ScrollViewObserver(scrollView: self, callback: { _ in callback() })

		let cancellable = Cancellable(observer: observer)
		observers[cancellable.uuid] = observer
		return cancellable
	}

	/// Observes content offset changes by calling the callback when the content offset changes.
	///
	/// **Warning**: don't accidentally retain this scroll view in the callback, otherwise you have a retain cycle.
	///
	/// - Parameters:
	///		- callback: the callback to call when the content offset changes
	///
	///	- Returns: a `ScrollViewObserverCancellable` that can be used to stop observing.
	@discardableResult public func observeContentOffsetChanges(_ callback: @escaping (UIScrollView) -> Void) -> ScrollViewObserverCancellable {
		let observer = ScrollViewObserver(scrollView: self, callback: callback)

		let cancellable = Cancellable(observer: observer)
		observers[cancellable.uuid] = observer
		return cancellable
	}

	private struct Cancellable: ScrollViewObserverCancellable {
		var uuid = UUID()
		weak var observer: ScrollViewObserver?

		func cancel() {
			observer?.scrollView?.observers.removeValue(forKey: uuid)
		}
	}

	private static var observersAssociatedObjectKey = 0
	private var observers: [UUID: ScrollViewObserver] {
		get {(objc_getAssociatedObject(self, &Self.observersAssociatedObjectKey) as? [UUID: ScrollViewObserver]) ?? [:] }
		set {objc_setAssociatedObject(self, &Self.observersAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
	}
}
