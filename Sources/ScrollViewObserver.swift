//
//  ScrollViewObserver.swift
//  ScrollViewObserver
//
//  Created by Andreas Verhoeven on 14/05/2020.
//  Copyright © 2020 Origin. All rights reserved.
//

import UIKit

/// Observes the contentOffset of a scrollview and calls a callback when it changes,
/// without touching the scroll views delegate
public class ScrollViewObserver: NSObject {
	/// the scroll view we are observing
	public private(set) weak var scrollView: UIScrollView?

	/// true if we are observing
	public private(set) var isObserving = false

	private var context = 0

	public typealias Callback = (UIScrollView) -> Void

	/// The callback to call when the scrollview scrolled
	public var callback: Callback? = nil {
		didSet {
			guard isObserving == true else {return}
			callCallback()
		}
	}

	/// Creates an observer for a scrollview
	///
	/// - Parameters:
	///		- scrollView: the scrollview to observe
	/// 	- callback: the callback to call when the scroll view scrolled
	public init(scrollView: UIScrollView, callback: Callback? = nil) {
		self.scrollView = scrollView
		self.callback = callback
		super.init()
		start()
	}

	/// Starts observing changes
	public func start() {
		guard isObserving == false else {return}
		isObserving = true
		scrollView?.addObserver(self, forKeyPath: "bounds", options: .new, context: &context)
		callCallback()
	}

	/// Stops observing changes
	public func stop() {
		guard isObserving == true else {return}
		isObserving = false
		scrollView?.removeObserver(self, forKeyPath: "bounds", context: &context)
	}
	
	deinit {
		stop()
	}

	// MARK: - Private
	func callCallback() {
		guard let scrollView = scrollView else {return}
		callback?(scrollView)
	}

	// MARK: - NSObject
	public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		guard context == &self.context else {return super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)}
		callCallback()
	}
}
