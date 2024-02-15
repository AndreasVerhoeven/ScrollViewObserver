//
//  UIScrollView+VisibilityToggler.swift
//  Demo
//
//  Created by Andreas Verhoeven on 16/05/2021.
//

import UIKit

extension UIScrollView {
	/// Toggles the visibility of a view when scrolling past another view.
	///
	/// - Parameters:
	///		- viewToToggle: **optional** the view to toggle the visibility of if `viewToMonitor` is scrolled out of view
	///		- style: **optional** the style that determines when to show/hide the `viewToToggle`, defaults to `.showWhenPastTreshold`
	///		- viewToMonitor: **optional** the view to use as a treshold
	///		- rectEdge: **optional** the edge of `viewToMonitor` to use as treshold, defaults to `.bottom`
	///		- visibilityUpdateCallback: **optional** callback that will be called to toggle the view's visibility - if not set, default will be used which changes alpha
	///
	///	- Returns: a `ScrollViewObserverCancellable` that can be used to stop toggling.
	@discardableResult public func toggleVisibility(
		of viewToToggle: UIView,
		style: ScrollViewVisibilityToggler.Style = .showWhenPastTreshold,
		whenScrollingPast viewToMonitor: UIView,
		edge: UIRectEdge = .bottom,
		visibilityUpdateCallback: ScrollViewVisibilityToggler.VisibilityUpdateCallback? = nil) -> ScrollViewObserverCancellable {
		let toggler = ScrollViewVisibilityToggler(scrollView: self, viewToMonitor: viewToMonitor, rectEdge: edge, viewToToggle: viewToToggle, style: style, visibilityUpdateCallback: visibilityUpdateCallback)
		return addToggler(toggler)
	}

	/// Toggles the visibility of a view when scrolling past a certain treshold.
	///
	/// - Parameters:
	///		- viewToToggle: **optional** the view to toggle the visibility of if `viewToMonitor` is scrolled out of view
	///		- style: **optional** the style that determines when to show/hide the `viewToToggle`, defaults to `.showWhenPastTreshold`
	///		- tresholdProvider: the callback that provides the treshold when to hide `viewToToggle`
	///		- visibilityUpdateCallback: **optional** callback that will be called to toggle the view's visibility - if not set, default will be used which changes alpha
	///
	///	- Returns: a `ScrollViewObserverCancellable` that can be used to stop toggling.
	@discardableResult public func toggleVisibility(
		of viewToToggle: UIView,
		style: ScrollViewVisibilityToggler.Style = .showWhenPastTreshold,
		tresholdProvider: @escaping ScrollViewOffsetMonitor.OffsetProvider,
		visibilityUpdateCallback: ScrollViewVisibilityToggler.VisibilityUpdateCallback? = nil) -> ScrollViewObserverCancellable {
		let toggler = ScrollViewVisibilityToggler(scrollView: self, viewToToggle: viewToToggle, style: style, tresholdProvider: tresholdProvider, visibilityUpdateCallback: visibilityUpdateCallback)
		return addToggler(toggler)
	}

	/// Toggles the visibility of a view when having scrolled past the inset
	///
	/// - Parameters:
	///		- viewToToggle: **optional** the view to toggle the visibility of if `viewToMonitor` is scrolled out of view
	///		- style: **optional** the style that determines when to show/hide the `viewToToggle`, defaults to `.showWhenPastTreshold`
	///		- visibilityUpdateCallback: **optional** callback that will be called to toggle the view's visibility - if not set, default will be used which changes alpha
	///
	///	- Returns: a `ScrollViewObserverCancellable` that can be used to stop toggling.
	@discardableResult public func toggleVisibility(
		of viewToToggle: UIView,
		style: ScrollViewVisibilityToggler.Style = .showWhenPastTreshold,
		visibilityUpdateCallback: ScrollViewVisibilityToggler.VisibilityUpdateCallback? = nil) -> ScrollViewObserverCancellable {
			return toggleVisibility(of: viewToToggle, style: style, tresholdProvider: { _ in 0 }, visibilityUpdateCallback: visibilityUpdateCallback)
	}


	fileprivate func addToggler(_ toggler: ScrollViewVisibilityToggler) -> ScrollViewObserverCancellable {
		let cancellable = Cancellable(toggler: toggler)
		observers[cancellable.uuid] = toggler
		return cancellable
	}

	private struct Cancellable: ScrollViewObserverCancellable {
		var uuid = UUID()
		weak var toggler: ScrollViewVisibilityToggler?

		func cancel() {
			toggler?.scrollView?.observers.removeValue(forKey: uuid)
		}
	}

	private static var observersAssociatedObjectKey = 0
	private var observers: [UUID: ScrollViewVisibilityToggler] {
		get {(objc_getAssociatedObject(self, &Self.observersAssociatedObjectKey) as? [UUID: ScrollViewVisibilityToggler]) ?? [:] }
		set {objc_setAssociatedObject(self, &Self.observersAssociatedObjectKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)}
	}
}

extension UICollectionView {
	/// Toggles the visibility of a view when scrolling past an index path
	///
	/// - Parameters:
	///		- viewToToggle: **optional** the view to toggle the visibility of if `viewToMonitor` is scrolled out of view
	///		- style: **optional** the style that determines when to show/hide the `viewToToggle`, defaults to `.showWhenPastTreshold`
	///		- indexPath: the index path to use as treshold
	///		- visibilityUpdateCallback: **optional** callback that will be called to toggle the view's visibility - if not set, default will be used which changes alpha
	///
	///	- Returns: a `ScrollViewObserverCancellable` that can be used to stop toggling.
	@discardableResult public func toggleVisibility(
		of viewToToggle: UIView,
		style: ScrollViewVisibilityToggler.Style = .showWhenPastTreshold,
		whenScrollingPast indexPath: IndexPath,
		visibilityUpdateCallback: ScrollViewVisibilityToggler.VisibilityUpdateCallback? = nil) -> ScrollViewObserverCancellable {
		let toggler = ScrollViewVisibilityToggler(collectionView: self, viewToToggle: viewToToggle, style: style, indexPath: indexPath, visibilityUpdateCallback: visibilityUpdateCallback)
		return addToggler(toggler)
	}
}

extension UITableView {
	/// Toggles the visibility of a view when scrolling past an index path
	///
	/// - Parameters:
	///		- viewToToggle:  the view to toggle the visibility of if `viewToMonitor` is scrolled out of view
	///		- style: **optional** the style that determines when to show/hide the `viewToToggle`, defaults to `.showWhenPastTreshold`
	///		- indexPath: the index path to use as treshold
	///		- visibilityUpdateCallback: **optional** callback that will be called to toggle the view's visibility - if not set, default will be used which changes alpha
	///
	///	- Returns: a `ScrollViewObserverCancellable` that can be used to stop toggling.
	@discardableResult public func toggleVisibility(
		of viewToToggle: UIView,
		style: ScrollViewVisibilityToggler.Style = .showWhenPastTreshold,
		whenScrollingPast indexPath: IndexPath,
		visibilityUpdateCallback: ScrollViewVisibilityToggler.VisibilityUpdateCallback? = nil) -> ScrollViewObserverCancellable {
			let toggler = ScrollViewVisibilityToggler(tableView: self, viewToToggle: viewToToggle, style: style, indexPath: indexPath, visibilityUpdateCallback: visibilityUpdateCallback)
		return addToggler(toggler)
	}
}


extension UINavigationItem {
	/// Sets a custom title view to this navigation item that gets shown when we scrolled past the given viewToMonitor.
	/// Note: the titleView is wrapped in another view to aid in toggling.
	///
	/// - Parameters:
	/// 	- titleView: the view to set as titleview and to toggle the visibility of
	/// 	- viewToMonitor: the view to
	///		- viewToMonitor: **optional** the view to use as a treshold
	/// 	- scrollView: the scrollView to check scrolling in
	///
	///	- Returns: a `ScrollViewObserverCancellable` that can be used to stop toggling.
	@discardableResult public func showCustomTitleView(
		_ titleView: UIView,
		whenScrollingPast viewToMonitor: UIView,
		in scrollView: UIScrollView
	) -> ScrollViewObserverCancellable {
		let (view, callback) = setupTitleView(with: titleView)
		return scrollView.toggleVisibility(of: view, whenScrollingPast: viewToMonitor, edge: .bottom, visibilityUpdateCallback: callback)
	}
	
	/// Sets a custom title view to this navigation item that gets shown when we scrolled past the given indexpath.
	/// Note: the titleView is wrapped in another view to aid in toggling.
	///
	/// - Parameters:
	/// 	- titleView: the view to set as titleview and to toggle the visibility of
	/// 	- indexPath: the index path to use as treshold
	/// 	- tableView: the tableView to check scrolling in
	///
	///	- Returns: a `ScrollViewObserverCancellable` that can be used to stop toggling.
	@discardableResult public func showCustomTitleView(
		_ titleView: UIView,
		whenScrollingPast indexPath: IndexPath,
		in tableView: UITableView
	) -> ScrollViewObserverCancellable {
		let (view, callback) = setupTitleView(with: titleView)
		return tableView.toggleVisibility(of: view, whenScrollingPast: indexPath, visibilityUpdateCallback: callback)
	}
	
	/// Sets a custom title view to this navigation item that gets shown when we scrolled past the given indexpath.
	/// Note: the titleView is wrapped in another view to aid in toggling.
	///
	/// - Parameters:
	/// 	- titleView: the view to set as titleview and to toggle the visibility of
	/// 	- indexPath: the index path to use as treshold
	/// 	- collectionView: the collectionView to check scrolling in
	///
	///	- Returns: a `ScrollViewObserverCancellable` that can be used to stop toggling.
	@discardableResult public func showCustomTitleView(
		_ titleView: UIView,
		whenScrollingPast indexPath: IndexPath,
		in collectionView: UICollectionView
	) -> ScrollViewObserverCancellable {
		let (view, callback) = setupTitleView(with: titleView)
		return collectionView.toggleVisibility(of: view, whenScrollingPast: indexPath, visibilityUpdateCallback: callback)
	}
	
	/// Sets up a title view and returns the (addedTitleView, updateCallback)
	private func setupTitleView(with titleView: UIView) -> (UIView, ScrollViewVisibilityToggler.VisibilityUpdateCallback) {
		let wrapperView = UIView()
		
		// we adjust the alpha and transform of this view
		let transformView = UIView()
		transformView.translatesAutoresizingMaskIntoConstraints = false
		wrapperView.addSubview(transformView)
		
		NSLayoutConstraint.activate([
			wrapperView.leadingAnchor.constraint(equalTo: transformView.leadingAnchor),
			wrapperView.trailingAnchor.constraint(equalTo: transformView.trailingAnchor),
			wrapperView.topAnchor.constraint(equalTo: transformView.topAnchor),
			wrapperView.bottomAnchor.constraint(equalTo: transformView.bottomAnchor),
		])
		
		titleView.translatesAutoresizingMaskIntoConstraints = false
		transformView.addSubview(titleView)
		
		NSLayoutConstraint.activate([
			transformView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor),
			transformView.trailingAnchor.constraint(equalTo: titleView.trailingAnchor),
			transformView.topAnchor.constraint(equalTo: titleView.topAnchor),
			transformView.bottomAnchor.constraint(equalTo: titleView.bottomAnchor),
		])
		
		self.titleView = wrapperView
		
		let callback: ScrollViewVisibilityToggler.VisibilityUpdateCallback = { view, shouldBeVisible, animated in
			let updates = {
				if shouldBeVisible == true {
					transformView.alpha = 1
					transformView.transform = .identity
				} else {
					transformView.alpha = 0
					transformView.transform = CGAffineTransform(translationX: 0, y: 10)
				}
			}
			
			if animated == true {
				UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: updates)
			} else {
				updates()
			}
		}
		
		return (wrapperView, callback)
	}
	
}
