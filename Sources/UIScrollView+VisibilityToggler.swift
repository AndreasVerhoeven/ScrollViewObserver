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
	///
	///	- Returns: a `ScrollViewObserverCancellable` that can be used to stop toggling.
	@discardableResult public func toggleVisibility(
		of viewToToggle: UIView,
		style: ScrollViewVisibilityToggler.Style = .showWhenPastTreshold,
		whenScrollingPast viewToMonitor: UIView,
		edge: UIRectEdge = .bottom) -> ScrollViewObserverCancellable {
		let toggler = ScrollViewVisibilityToggler(scrollView: self, viewToMonitor: viewToMonitor, rectEdge: edge, viewToToggle: viewToToggle, style: style)
		return addToggler(toggler)
	}

	/// Toggles the visibility of a view when scrolling past a certain treshold.
	///
	/// - Parameters:
	///		- viewToToggle: **optional** the view to toggle the visibility of if `viewToMonitor` is scrolled out of view
	///		- style: **optional** the style that determines when to show/hide the `viewToToggle`, defaults to `.showWhenPastTreshold`
	///		- tresholdProvider: the callback that provides the treshold when to hide `viewToToggle`
	///
	///	- Returns: a `ScrollViewObserverCancellable` that can be used to stop toggling.
	@discardableResult public func toggleVisibility(
		of viewToToggle: UIView,
		style: ScrollViewVisibilityToggler.Style = .showWhenPastTreshold,
		tresholdProvider: @escaping ScrollViewOffsetMonitor.OffsetProvider) -> ScrollViewObserverCancellable {
		let toggler = ScrollViewVisibilityToggler(scrollView: self, viewToToggle: viewToToggle, style: style, tresholdProvider: tresholdProvider)
		return addToggler(toggler)
	}

	/// Toggles the visibility of a view when having scrolled past the inset
	///
	/// - Parameters:
	///		- viewToToggle: **optional** the view to toggle the visibility of if `viewToMonitor` is scrolled out of view
	///		- style: **optional** the style that determines when to show/hide the `viewToToggle`, defaults to `.showWhenPastTreshold`
	///
	///	- Returns: a `ScrollViewObserverCancellable` that can be used to stop toggling.
	@discardableResult public func toggleVisibility(
		of viewToToggle: UIView,
		style: ScrollViewVisibilityToggler.Style = .showWhenPastTreshold) -> ScrollViewObserverCancellable {
		return toggleVisibility(of: viewToToggle, style: style, tresholdProvider: { $0.adjustedContentInset.top })
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
	///
	///	- Returns: a `ScrollViewObserverCancellable` that can be used to stop toggling.
	@discardableResult public func toggleVisibility(
		of viewToToggle: UIView,
		style: ScrollViewVisibilityToggler.Style = .showWhenPastTreshold,
		whenScrollingPast indexPath: IndexPath) -> ScrollViewObserverCancellable {
		let toggler = ScrollViewVisibilityToggler(collectionView: self, viewToToggle: viewToToggle, style: style, indexPath: indexPath)
		return addToggler(toggler)
	}
}

extension UITableView {
	/// Toggles the visibility of a view when scrolling past an index path
	///
	/// - Parameters:
	///		- viewToToggle: **optional** the view to toggle the visibility of if `viewToMonitor` is scrolled out of view
	///		- style: **optional** the style that determines when to show/hide the `viewToToggle`, defaults to `.showWhenPastTreshold`
	///		- indexPath: the index path to use as treshold
	///
	///	- Returns: a `ScrollViewObserverCancellable` that can be used to stop toggling.
	@discardableResult public func toggleVisibility(
		of viewToToggle: UIView,
		style: ScrollViewVisibilityToggler.Style = .showWhenPastTreshold,
		whenScrollingPast indexPath: IndexPath) -> ScrollViewObserverCancellable {
		let toggler = ScrollViewVisibilityToggler(tableView: self, viewToToggle: viewToToggle, style: style, indexPath: indexPath)
		return addToggler(toggler)
	}
}
