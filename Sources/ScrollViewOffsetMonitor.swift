//
//  ScrollViewOffsetMonitor.swift
//  ScrollViewObserver
//
//  Created by Andreas Verhoeven on 14/05/2020.
//  Copyright © 2020 Origin. All rights reserved.
//

import UIKit

/// Monitors if a scrollview scrolls past a specific treshold.
/// If the scroll view crosses the treshold, a callback is called.
public class ScrollViewOffsetMonitor: NSObject {

	/// The callback to call when the treshold is crossed
	public var callback: Callback?

	/// the callback that provides the treshold we should monitor for crossing,
	/// if `nil` the treshold from `defaultTreshold()` is used, which
	/// returns the start of the first section for a table view, or just the start
	/// of the content for any other scroll view.
	public var tresholdProvider: OffsetProvider?

	/// the callback that provides the scrollview's current scroll offset.
	/// If nil, `defaultOffset()` is used, which uses the regular offset
	/// of a scroll view.
	/// Not overriding this is usually fine, but if you need to use a different
	/// offset, you can set this callback.
	public var scrollViewOffsetProvider: OffsetProvider?

	/// The callback that determines if the scroll view scrolled past
	/// the treshold. If `nil`, `defaultShouldBeVisibile()` will be called
	/// which simply check if `offset > treshold`.
	public var visibilityProvider: VisibilityProvider?

	/// true if we are past the treshold
	public private(set) var isOverTreshold: Bool = false

	/// true if we are currently monitoring
	public var isMonitoring: Bool {
		return observer.isObserving
	}

	/// the scroll view we are monitoring
	public weak var scrollView: UIScrollView? {
		return observer.scrollView
	}

	private var observer: ScrollViewObserver

	public typealias OffsetProvider = (_ scrollView: UIScrollView) -> CGFloat
	public typealias Callback = (_ isOverTreshold: Bool) -> Void
	public typealias VisibilityProvider = (_ scrollView: UIScrollView) -> Bool

	/// Creates an monitor
	///
	/// - Parameters:
	///		- scrollView: the scroll view to monitor
	///		- scrollViewOffsetProvider: **optional** custom offset provider for the scrollview
	///		- tresholdProvider: **optional** custom treshold provider for the monitor
	///		- visibilityProvider: **optional** custom visibility provider for the monitor
	///		- callback: **optional** the callback that will be called when crossing the treshold
	public init(scrollView: UIScrollView,
				scrollViewOffsetProvider: OffsetProvider? = nil,
				tresholdProvider: OffsetProvider? = nil,
				visibilityProvider: VisibilityProvider? = nil,
				callback: Callback? = nil) {
		self.observer = ScrollViewObserver(scrollView: scrollView)
		self.scrollViewOffsetProvider = scrollViewOffsetProvider
		self.tresholdProvider = tresholdProvider
		self.visibilityProvider = visibilityProvider
		self.callback = callback
		super.init()

		self.observer.callback = {[weak self] _ in self?.update()}
		self.update()
	}

	/// Starts monitoring
	public func start() {
		observer.start()
	}

	/// Stops monitoring
	public func stop() {
		observer.stop()
	}

	/// performs an update, just like as if the scroll view scrolled. Pass `force: true` to always call the callback,
	/// even if we didn't cross the treshold.
	///
	/// - Parameters:
	/// 	- force: **optional** if yes, the callback will always be called
	///
	public func update(force: Bool = false) {
		guard let scrollView = observer.scrollView else {return}
		let newValue = shouldBeVisible(in: scrollView)
		if newValue != isOverTreshold || force {
			isOverTreshold = newValue
			callback?(isOverTreshold)
		}
	}

	/// Default treshold provider, you can call this from a custom callback to dynamically override behavior
	public func defaultTreshold(in scrollView: UIScrollView) -> CGFloat {
		guard let tableView = scrollView as? UITableView, tableView.numberOfSections > 0 && tableView.tableHeaderView == nil else {
			return -scrollView.adjustedContentInset.top
		}
		return tableView.rect(forSection: 0).minY
	}

	/// Default offset provider, you can call this from a custom callback to dynamically override behavior
	public func defaultOffset(in scrollView: UIScrollView) -> CGFloat {
		scrollView.contentOffset.y + scrollView.adjustedContentInset.top
	}

	/// Default should be visible, you can call this from a custom callback to dynamically override behavior
	public func defaultShouldBeVisibile(in scrollView: UIScrollView) -> Bool {
		return scrollViewOffset(in: scrollView) > treshold(in: scrollView)
	}

	// MARK: - Private
	private func scrollViewOffset(in scrollView: UIScrollView) -> CGFloat {
		return scrollViewOffsetProvider?(scrollView) ?? defaultOffset(in: scrollView)
	}
	private func treshold(in scrollView: UIScrollView) -> CGFloat {
		tresholdProvider?(scrollView) ?? defaultTreshold(in: scrollView)
	}

	private func shouldBeVisible(in scrollView: UIScrollView) -> Bool {
		return visibilityProvider?(scrollView) ?? defaultShouldBeVisibile(in: scrollView)
	}
}
