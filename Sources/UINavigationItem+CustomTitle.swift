//
//  UINavigationItem+CustomTitle.swift
//  Demo
//
//  Created by Andreas Verhoeven on 06/03/2024.
//

import UIKit

extension UINavigationItem {
	/// This view is used to wrap our Custom TitleView, so we can properly transform and change the opacity
	/// of the intermediate wrapperView without changing the titleView, which is under control of the navigation bar
	/// our changing the customTitleView set by the user, which is under user control
	private class CustomTitleWrapperView: UIView {
		let transformView = UIView()
		
		var view: UIView? {
			didSet {
				guard view !== oldValue else { return }
				oldValue?.removeFromSuperview()
				
				if let view {
					view.translatesAutoresizingMaskIntoConstraints = false
					view.setContentCompressionResistancePriority(.navigationBarCustomTitleView, for: .horizontal)
					transformView.addSubview(view)
					
					NSLayoutConstraint.activate([
						transformView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
						transformView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
						transformView.topAnchor.constraint(equalTo: view.topAnchor),
						transformView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
					])
				}
			}
		}
		
		var updateCallback: ScrollViewVisibilityToggler.VisibilityUpdateCallback {
			return { view, shouldBeVisible, animated in
				let updates = {
					guard let transformView = (view as? CustomTitleWrapperView)?.transformView else { return }
					
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
		}
		
		override init(frame: CGRect) {
			super.init(frame: frame)
			
			transformView.translatesAutoresizingMaskIntoConstraints = false
			addSubview(transformView)
			NSLayoutConstraint.activate([
				leadingAnchor.constraint(equalTo: transformView.leadingAnchor),
				trailingAnchor.constraint(equalTo: transformView.trailingAnchor),
				topAnchor.constraint(equalTo: transformView.topAnchor),
				bottomAnchor.constraint(equalTo: transformView.bottomAnchor),
			])
		}
		
		@available(*, unavailable)
		required init?(coder: NSCoder) {
			fatalError("not implemented")
		}
	}
	
	private class CustomTitleLabelWrapperView: CustomTitleWrapperView {
		let label = UILabel()
		
		weak var viewToMonitor: UIView?
		weak var scrollView: UIView?
		var cancellable: ScrollViewObserverCancellable?
		var indexPath: IndexPath?
		
		override init(frame: CGRect) {
			super.init(frame: frame)
			
			label.adjustsFontForContentSizeCategory = true
			if #available(iOS 15, *) {
				label.minimumContentSizeCategory = .large
				label.maximumContentSizeCategory = .extraExtraLarge
			}
			label.font = UIFont.preferredFont(forTextStyle: .headline)
			label.textAlignment = .center
			label.numberOfLines = 1
			label.setContentCompressionResistancePriority(.navigationBarCustomTitleView, for: .horizontal)
			
			_ = { view = label }()
		}
	}
	
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
		let wrapperView = customTitleWrapperView(with: titleView)
		return scrollView.toggleVisibility(of: wrapperView, whenScrollingPast: viewToMonitor, edge: .bottom, visibilityUpdateCallback: wrapperView.updateCallback)
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
		let wrapperView = customTitleWrapperView(with: titleView)
		return tableView.toggleVisibility(of: wrapperView, whenScrollingPast: indexPath, visibilityUpdateCallback: wrapperView.updateCallback)
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
		let wrapperView = customTitleWrapperView(with: titleView)
		return collectionView.toggleVisibility(of: wrapperView, whenScrollingPast: indexPath, visibilityUpdateCallback: wrapperView.updateCallback)
	}
	
	/// Sets a custom title to this navigation item that gets shown when we scrolled past the given viewToMonitor.
	/// Note: the titleView is wrapped in another view to aid in toggling.
	///
	/// - Parameters:
	/// 	- title: the title to set when visible
	/// 	- viewToMonitor: the view to
	///		- viewToMonitor: **optional** the view to use as a treshold
	/// 	- scrollView: the scrollView to check scrolling in
	///
	///	- Returns: a `ScrollViewObserverCancellable` that can be used to stop toggling.
	@discardableResult public func showCustomTitle(
		_ title: String?,
		whenScrollingPast viewToMonitor: UIView,
		in scrollView: UIScrollView
	) -> ScrollViewObserverCancellable {
		return customTitleLabelView(with: title, viewToMonitor: viewToMonitor, indexPath: nil, scrollView: scrollView) { wrapperView in
			return scrollView.toggleVisibility(of: wrapperView, whenScrollingPast: viewToMonitor, edge: .bottom, visibilityUpdateCallback: wrapperView.updateCallback)
		}
	}
	
	/// Sets a custom title view to this navigation item that gets shown when we scrolled past the given indexpath.
	/// Note: the titleView is wrapped in another view to aid in toggling.
	///
	/// - Parameters:
	/// 	- title: the title to set when visible
	/// 	- indexPath: the index path to use as treshold
	/// 	- tableView: the tableView to check scrolling in
	///
	///	- Returns: a `ScrollViewObserverCancellable` that can be used to stop toggling.
	@discardableResult public func showCustomTitle(
		_ title: String?,
		whenScrollingPast indexPath: IndexPath,
		in tableView: UITableView
	) -> ScrollViewObserverCancellable {
		return customTitleLabelView(with: title, viewToMonitor: nil, indexPath: indexPath, scrollView: tableView) { wrapperView in
			return tableView.toggleVisibility(of: wrapperView, whenScrollingPast: indexPath, visibilityUpdateCallback: wrapperView.updateCallback)
		}
	}
	
	/// Sets a custom title view to this navigation item that gets shown when we scrolled past the given indexpath.
	/// Note: the titleView is wrapped in another view to aid in toggling.
	///
	/// - Parameters:
	/// 	- title: the title to set when visible
	/// 	- indexPath: the index path to use as treshold
	/// 	- collectionView: the collectionView to check scrolling in
	///
	///	- Returns: a `ScrollViewObserverCancellable` that can be used to stop toggling.
	@discardableResult public func showCustomTitle(
		_ title: String?,
		whenScrollingPast indexPath: IndexPath,
		in collectionView: UICollectionView
	) -> ScrollViewObserverCancellable {
		return customTitleLabelView(with: title, viewToMonitor: nil, indexPath: indexPath, scrollView: collectionView) { wrapperView in
			return collectionView.toggleVisibility(of: wrapperView, whenScrollingPast: indexPath, visibilityUpdateCallback: wrapperView.updateCallback)
		}
	}
	
	/// Updates a custom title previously set by `showCustomTitle()`
	///
	/// - Parameters:
	/// 	- title: the title to set when visible
	/// 	- indexPath: the index path to use as treshold
	/// 	- collectionView: the collectionView to check scrolling in
	///
	public func updateCustomTitle(_ title: String?, animated: Bool) {
		guard let wrapperView = titleView as? CustomTitleLabelWrapperView else {
			print("titleView is not set by a previous invocation of showCustomTitle() - nothing will be updated")
			return
		}
		
		self.title = title
		if animated == true && wrapperView.label.text != title {
			UIView.transition(with: wrapperView.label, duration: 0.25, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
				wrapperView.label.text = title
			})
		} else {
			wrapperView.label.text = title
		}
	}
	
	/// Sets up a title view and returns the created wrapper view
	private func customTitleWrapperView(with customTitleView: UIView) -> CustomTitleWrapperView {
		let wrapperView: CustomTitleWrapperView
		if let titleView = titleView as? CustomTitleWrapperView, (titleView is CustomTitleLabelWrapperView) == false {
			wrapperView = titleView
		} else {
			wrapperView = CustomTitleWrapperView()
		}
		
		wrapperView.view = customTitleView
		titleView = wrapperView
		return wrapperView
	}
	
	/// Sets up a title and returns the  created titlewrapperview
	private func customTitleLabelView(with title: String?, viewToMonitor: UIView?, indexPath: IndexPath?, scrollView: UIScrollView, creation: (CustomTitleLabelWrapperView) -> ScrollViewObserverCancellable) -> ScrollViewObserverCancellable  {
		let wrapperView = (titleView as? CustomTitleLabelWrapperView) ?? CustomTitleLabelWrapperView()
		wrapperView.label.text = title
		
		if wrapperView.viewToMonitor !== viewToMonitor || wrapperView.indexPath != indexPath || wrapperView.scrollView !== scrollView {
			wrapperView.cancellable?.cancel()
			wrapperView.cancellable = nil
		}
		
		wrapperView.viewToMonitor = viewToMonitor
		wrapperView.indexPath = indexPath
		wrapperView.scrollView = scrollView
		
		self.title = title
		titleView = wrapperView
		if let cancellable = wrapperView.cancellable {
			return cancellable
		} else {
			let cancellable = creation(wrapperView)
			wrapperView.cancellable = cancellable
			return cancellable
		}
	}
}

fileprivate extension UILayoutPriority {
	static let navigationBarSpacing = Self(rawValue: 700)
	static let navigationBarCustomTitleView = Self(rawValue: Self.navigationBarSpacing.rawValue - 1)
}
