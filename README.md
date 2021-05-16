# ScrollViewObserver
Observer any UIScrollView without setting a delegate

## What?
This small library provides a few utility classes and helper methods for observing scroll offset changes in a `UIScrollView` without having to set the delegate.

Furthermore, there are also helpers to automatically fire of a callback when a certain (dynamically determined) treshold is crossed and to show/hide views automatically based on the scroll offset.


## Observing Content Offset

### Convenience Method

There's a convenience helper you can call to quickly start observing scroll offset changes:  `UIScrollView.observeContentOffsetChanges()`. 

This method returns a `ScrollViewObserverCancellable` that you can use to stop observing. If you'll never stop observing, you can simply ignore the return value.

**Warning:** don't strongly retain the scroll view in the call back block, otherwise you'll have a retain cycle.


#### Example 1: 
```
// prints content offset changes for the next 10 seconds
let cancellable = scrollView.observeContentOffsetChanges { scrollView in
	print(scrollView.contentOffset) 
}
DispatchQueue.main.asyncAfter(.now() + 10) {
	cancellable.cancel()
}

```

#### Example 2:
```
// there's also a version that doesn't take a scroll view as parameter
scrollView.observeContentOffsetChanges { [weak self] in
	self?.doSomethingWhenWeScroll()
}

```

### `ScrollViewObserver`

The convenience method wraps and keeps track of `ScrollViewObserver`. You can also keep track of this yourself.

```
class UIViewController {
	var observer: ScrollViewObserver!
	
	func viewDidLoad() {
		super.viewDidLoad()
		
		// here we manually track an observer object. We need to hold on to it, because
		// when it is deallocated, the observing will stop
		observer = ScrollViewObserver(scrollView: scrollView) { scrollView _ 
			print(scrollView.contentOffset)
		}
	}
}

```

## Monitoring Offset Tresholds

There's also a helper method to keep track of when a specific treshold is crossed and only fire a callback when we cross the treshold. This can be used, for example, to toggle

### Convenience Method

`UIScrollView.monitorOffsetTreshold()`

This method returns a `ScrollViewObserverCancellable` that you can use to stop observing. If you'll never stop observing, you can simply ignore the return value.

**Warning:** don't strongly retain the scroll view in the call back block, otherwise you'll have a retain cycle.


#### Example:
```
// This prints "A" if we scrolled to the first half of the scroll view and "B" in the second half.

let cancellable = scrollView.monitorOffsetTreshold(tresholdProvider: { scrollView in
		return scrollView.contentSize.height * 0.5
	}, callback: { isOverTreshold in 
		if isOverTreshold {
			print("A")
		} else {
			print("B"")
		}
	})
```

You can also provide a custom:
	- `contentOffsetProvider`, which tells the monitor where the scroll view is. Usually, the default implementation is suitable.
	-a custom `visibilityProvider` which tells the monitor if we crossed the treshold. The default implementation does `offset > treshold` and is usually suitable.


### `ScrollViewOffsetMonitor`

The convenience method wraps and tracks a `ScrollViewOffsetMonitor` object. You can also keep track of this yourself:

```
class UIViewController {
	var monitor: ScrollViewOffsetMonitor!

	func viewDidLoad() {
		super.viewDidLoad()

		// here we manually track a monitor object. We need to hold on to it, because
		// 	when it is deallocated, the observing will stop
		monitor = ScrollViewOffsetMonitor(scrollView: scrollView,tresholdProvider: { scrollView in 
			return scrollView.contentSize.height * 0.5
		}, callback: { isOverTreshold in 
			if isOverTreshold {
				print("A")
			} else {
				print("B"")
			}
		})
	}
}
```


## Automatic Hiding/Showing Views Based on Scroll ContentOffset

There's a helper class (and convenience methods) that automatically hide/show a view (by setting the alpha) based on if a specific treshold has been crossed in the scrollview.

This can be used to, for example, hide a label when a header view is visible.

### Convenience

- `UIScrollView.toggleVisibility()`
- `UITableView.toggleVisibility()`
- `UICollectionView.toggleVisibility()`

These methods returns a `ScrollViewObserverCancellable` that you can use to stop observing. If you'll never stop observing, you can simply ignore the return value.

**Warning:** don't strongly retain the scroll view in the call back block, otherwise you'll have a retain cycle.

#### Example:

```

// this will automatically hide the `someLabel` when we haven't scrolled past
// the top of `someOtherView`
let cancellable = scrollView.toggleVisibility(
						of: someLabel,
						style: .showWhenPastTreshold,
						whenScrollingPast: someOtherView,
						edge: .top)
						

// this will automatically  hide `someLabel` when we scrolled past the bottom of `someOtherView`
scrollView.toggleVisibility(of: someLabel, style: .hideWhenPastTreshold, whenScrollingPast: someOtherView)

// this will automaticaly hide `someLabel` when we scrolled past row 1 of section 0
tableView.toggleVisibility(of: someLabel, whenScrollingPast: IndexPath(row: 1, section: 0)

// this will automatically show `someLabel` when we scrolled past row 1 of section 0
let cancelleble = collectionView.toggleVisibility(of: someLabel, style: .hideWhenPastTreshold, whenScrollingPast: IndexPath(row: 1, section: 0)

```


### `ScrollViewVisibilityToggler`

The convenience methods wrap and track a `ScrollViewVisibilityToggler` object. You can also keep track of this yourself:

```
class UIViewController {
	var toggler: ScrollViewVisibilityToggler!

	func viewDidLoad() {
		super.viewDidLoad()

		// here we manually track a toggler object. We need to hold on to it, because
		// 	when it is deallocated, the observing will stop
		toggler = ScrollViewVisibilityToggler(scrollView: scrollView, viewToMonitor: someOtherView, viewToToggle: someLabel)
	}
}
```
