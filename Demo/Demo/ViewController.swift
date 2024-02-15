//
//  ViewController.swift
//  Demo
//
//  Created by Andreas Verhoeven on 16/05/2021.
//

import UIKit

class ViewController: UITableViewController {
	var cancellable: ScrollViewObserverCancellable?

	override func viewDidLoad() {
		super.viewDidLoad()

		/// We use a custom title view which we will hide when scrolling past a certain index path
		let label = UILabel()
		label.font = UIFont.preferredFont(forTextStyle: .headline)
		label.textAlignment = .center
		label.text = "Title of this view"
		label.sizeToFit()
		//navigationItem.titleView = label

		// We create a toggler that hides the label when we scroll past the 3rd row of the first section.
		// We also keep track of the cancellable, to stop this toggling when a user taps on another row.
		//
		// (Note that if you have no plans of stopping the toggling, you don't need to keep track of the cancellable)
		cancellable = tableView.toggleVisibility(of: label, style: .hideWhenPastTreshold,  whenScrollingPast: IndexPath(row: 3, section: 0))
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 10
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 5
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
		cell.textLabel?.text = String(describing: indexPath)
		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let label = navigationItem.titleView else { return }

		// We first cancel the previous toggler
		cancellable?.cancel()

		// and create a new one for the tapped index path
		cancellable = tableView.toggleVisibility(of: label, style: .hideWhenPastTreshold,  whenScrollingPast: indexPath)
	}
}

