//
//  ScrollViewVisibilityToggler.swift
//  ScrollViewObserver
//
//  Created by Andreas Verhoeven on 14/05/2020.
//  Copyright © 2020 Origin. All rights reserved.
//

import UIKit

/// Toggles the visibility of a view (by setting the alpha to 0 or 1)
/// if the view scrolled was scrolled out of view.
public class ScrollViewVisibilityToggler: NSObject {

	public enum Style {
		/// shows the `viewToToggle` when we are past the treshold
		case showWhenPastTreshold

		/// hides the view when we are past the treshold
		case hideWhenPastTreshold
	}

	/// the style of this toggler: either `hideWhenPastTreshold` or `showWhenPastTreshold`
	/// `viewToMonitor` is scrolled out of view.
	public var style: Style {didSet {updateForChanges()}}

	/// The rect edge of `viewToMonitor` to use as treshold for determining
	/// if we should hide `viewToToggle`.
	/// E.g. if set to `.top`, we will hide `viewToToggle` when the top of the
	/// `viewToMonitor` is scrolled out of view.
	public var rectEdge: UIRectEdge {didSet {updateForChanges()}}

	/// the view to use as a treshold. When this view is scrolled out of view,
	/// we'll hide `viewToToggle`.
	public var viewToMonitor: UIView? {didSet {updateForChanges()}}

	/// The view to toggle the visibility of. Can be the same as `viewToMonitor`.
	public var viewToToggle: UIView? {didSet {updateForChanges()}}
	public var monitor: ScrollViewOffsetMonitor

	/// Callback that determines the offset in the scroll view we are monitoring.
	/// If `nil`, the default offset will be used.
	public var scrollViewOffsetProvider: ScrollViewOffsetMonitor.OffsetProvider? {
		get{monitor.scrollViewOffsetProvider}
		set{monitor.scrollViewOffsetProvider = newValue}
	}

	/// Callback that determines the treshold of when to hide `viewToToggle`.
	/// If `nil`, the default implementation will track `viewToMonitor`.
	public var tresholdProvider: ScrollViewOffsetMonitor.OffsetProvider? {
		get {monitor.tresholdProvider}
		set {monitor.tresholdProvider = newValue}
	}

	/// the scrollview we are monitoring
	public weak var scrollView: UIScrollView? {
		return monitor.scrollView
	}

	/// Creates a toggler
	///
	/// - Parameters:
	///		- scrollView: the scroll view to monitor
	///		- viewToMonitor: **optional** the view to use as a treshold
	///		- rectEdge: **optional** the edge of `viewToMonitor` to use as treshold, defaults to `.bottom`
	///		- viewToToggle: **optional** the view to toggle the visibility of if `viewToMonitor` is scrolled out of view
	///		- style: **optional** the style that determines when to show/hide the `viewToToggle`, defaults to `.showWhenPastTreshold`
	public init(scrollView: UIScrollView,
				viewToMonitor: UIView? = nil,
				rectEdge: UIRectEdge = .bottom,
				viewToToggle: UIView? = nil,
				style: Style = .showWhenPastTreshold) {
		self.rectEdge = rectEdge
		self.viewToMonitor = viewToMonitor
		self.viewToToggle = viewToToggle
		self.style = style
		self.monitor = ScrollViewOffsetMonitor(scrollView: scrollView)
		super.init()

		monitor.tresholdProvider = { [weak self] scrollView in
			guard let self = self else {return 0}
			guard let viewToMonitor = self.viewToMonitor else {return self.monitor.defaultTreshold(in: scrollView)}
			let frame = viewToMonitor.convert(viewToMonitor.bounds, to: scrollView)
			switch self.rectEdge {
				case .top: return frame.minY
				case .left: return frame.minX
				case .bottom: return frame.maxY
				case .right: return frame.maxX
				case .all: return frame.maxY
				default: return frame.maxY
			}
		}
		monitor.callback = { [weak self] _ in self?.update() }
		self.updateForChanges()
	}

	/// Creates a toggler with a custom offset provider
	///
	/// - Parameters:
	///		- scrollView: the scroll view to monitor
	///		- viewToToggle: **optional** the view to toggle the visibility of if the treshold is reached
	///		- style: **optional** the style that determines when to show/hide the `viewToToggle`, defaults to `.showWhenPastTreshold`
	///		- tresholdProvider: the callback that provides the treshold when to hide `viewToToggle`
	public convenience init(scrollView: UIScrollView,
							viewToToggle: UIView? = nil,
							style: Style = .showWhenPastTreshold,
							tresholdProvider: @escaping ScrollViewOffsetMonitor.OffsetProvider) {
		self.init(scrollView: scrollView, viewToToggle: viewToToggle, style: style)

		self.tresholdProvider = tresholdProvider
	}

	/// Creates a toggle that hides a view when a specific indexPath in a `UICollectionView` is scrolled out of view
	///
	///	- Parameters:
	///		- collectionView: the collection view to monitor
	///		- viewToToggle: **optional** the view to toggle the visibility of if the index path is scrolled out of view
	///		- style: **optional** the style that determines when to show/hide the `viewToToggle`, defaults to `.showWhenPastTreshold`
	///		- indexPath: the index path to use as treshold
	public convenience init(collectionView: UICollectionView,
							viewToToggle: UIView? = nil,
							style: Style = .showWhenPastTreshold,
							indexPath: IndexPath) {
		self.init(scrollView: collectionView, viewToToggle: viewToToggle, style: style)
		
		self.tresholdProvider = { [weak self] scrollView in
			guard collectionView.isValidIndexPath(indexPath) else {return self?.monitor.defaultTreshold(in: collectionView) ?? 0}
			return collectionView.layoutAttributesForItem(at: indexPath)?.frame.maxY ?? self?.monitor.defaultTreshold(in: collectionView) ?? 0
		}
		self.updateForChanges()
	}

	/// Creates a toggle that hides a view when a specific indexPath in a `UITableView` is scrolled out of view
	///
	///	- Parameters:
	///		- tableView: the table view to monitor
	///		- viewToToggle: **optional** the view to toggle the visibility of if the index path is scrolled out of view
	///		- style: **optional** the style that determines when to show/hide the `viewToToggle`, defaults to `.showWhenPastTreshold`
	///		- indexPath: the index path to use as treshold
	public convenience init(tableView: UITableView,
							viewToToggle: UIView? = nil,
							style: Style = .showWhenPastTreshold,
							indexPath: IndexPath) {
		self.init(scrollView: tableView, viewToToggle: viewToToggle, style: style)

		self.tresholdProvider = { [weak self] scrollView in
			guard tableView.isValidIndexPath(indexPath) else {return self?.monitor.defaultTreshold(in: tableView) ?? 0}
			return tableView.rectForRow(at: indexPath).maxY
		}
		self.updateForChanges()
	}

	/// starts monitoring
	public func start() {
		monitor.start()
	}

	/// stops monitoring
	public func stop() {
		monitor.stop()
	}

	// MARK: - Private
	private func updateForChanges() {
		monitor.update()
		update()
	}
	private func update() {
		guard let viewToToggle = viewToToggle else {return}
		let isOverTreshold = monitor.isOverTreshold
		UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
			switch self.style {
				case .showWhenPastTreshold:
					viewToToggle.alpha = (isOverTreshold == true ? 1 : 0)

				case .hideWhenPastTreshold:
					viewToToggle.alpha = (isOverTreshold == true ? 0 : 1)
			}
		})
	}
}


fileprivate extension UICollectionView {
	func isValidIndexPath(_ indexPath: IndexPath) -> Bool {
		return indexPath.section < numberOfSections && indexPath.row < numberOfItems(inSection: indexPath.section)
	}
}


fileprivate extension UITableView {
	func isValidIndexPath(_ indexPath: IndexPath) -> Bool {
		return indexPath.section < numberOfSections && indexPath.row < numberOfRows(inSection: indexPath.section)
	}
}