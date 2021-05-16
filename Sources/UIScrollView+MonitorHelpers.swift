//
//  UIScrollView+MonitorHelpers.swift
//  Demo
//
//  Created by Andreas Verhoeven on 16/05/2021.
//

import UIKit

extension UIScrollView {
	/// Monitors the offset in a UIScrollView and calls a block when it goes over a specific treshold.
	///
	/// **Warning**: don't accidentally retain this scroll view in the callback, otherwise you have a retain cycle.
	///
	/// - Parameters:
	///		- scrollViewOffsetProvider: **optional** custom offset provider for the scrollview
	///		- tresholdProvider: **optional** custom treshold provider for the monitor
	///		- visibilityProvider: **optional** custom visibility provider for the monitor
	///		- callback: the callback that will be called when crossing the treshold
	///
	///	- Returns: a `ScrollViewObserverCancellable` that can be used to stop observing.
	@discardableResult public func monitorOffsetTreshold(
		scrollViewOffsetProvider: ScrollViewOffsetMonitor.OffsetProvider? = nil,
		tresholdProvider: ScrollViewOffsetMonitor.OffsetProvider? = nil,
		visibilityProvider: ScrollViewOffsetMonitor.VisibilityProvider? = nil,
		callback: @escaping ScrollViewOffsetMonitor.Callback) -> ScrollViewObserverCancellable {
		let monitor = ScrollViewOffsetMonitor(scrollView:self,
											  scrollViewOffsetProvider: scrollViewOffsetProvider,
											  tresholdProvider: tresholdProvider,
											  visibilityProvider: visibilityProvider,
											  callback: callback)

		let cancellable = Cancellable(monitor: monitor)
		observers[cancellable.uuid] = monitor
		return cancellable

	}

	private struct Cancellable: ScrollViewObserverCancellable {
		var uuid = UUID()
		weak var monitor: ScrollViewOffsetMonitor?

		func cancel() {
			monitor?.scrollView?.observers.removeValue(forKey: uuid)
		}
	}

	private static var observersAssociatedObjectKey = 0
	private var observers: [UUID: ScrollViewOffsetMonitor] {
		get {(objc_getAssociatedObject(self, &Self.observersAssociatedObjectKey) as? [UUID: ScrollViewOffsetMonitor]) ?? [:] }
		set {objc_setAssociatedObject(self, &Self.observersAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
	}
}
