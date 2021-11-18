//
//  BookmarksViewController.swift
//  Podcast
//
//  Created by Gerrit Goossen <developer@gerrit.email> on 11/17/21.
//  Copyright © 2021 TuneURL Inc. All rights reserved.
//

import UIKit

class BookmarksViewController: UITableViewController {

	// MARK: - UIViewController

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.tableView.reloadData()
		NotificationCenter.default.addObserver(forName: BookmarkCollection.changedNotification, object: nil, queue: nil) { notification in
			self.tableView.reloadData()
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		NotificationCenter.default.removeObserver(self)
	}

	// MARK: - UITableViewDataSource

	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "BookmarkCell", for: indexPath)
		var bookmark: Bookmark?
		if (indexPath.row < BookmarkCollection.shared.bookmarks.count) {
			bookmark = BookmarkCollection.shared.bookmarks[indexPath.row]
		}
		cell.textLabel?.text = bookmark?.name ?? ""
		return cell
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return BookmarkCollection.shared.bookmarks.count
	}

	// MARK: - UITableViewDelegate

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard (indexPath.row < BookmarkCollection.shared.bookmarks.count),
			  let bookmarkURL = URL(string: BookmarkCollection.shared.bookmarks[indexPath.row].url) else {
			return
		}
		// open web page
		UIApplication.shared.open(bookmarkURL, options: [:], completionHandler: nil)
		self.tableView.deselectRow(at: indexPath, animated: true)
	}

	override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
		// setup the delete action
		let deleteAction = UIContextualAction(style: .destructive, title: nil) {
			action, sourceView, completionHandler in
			// delete the bookmark
			BookmarkCollection.shared.removeBookmark(at: indexPath.row)
//			self.tableView.deleteRows(at: [indexPath], with: .left)
			completionHandler(true)
		}
		deleteAction.backgroundColor = .systemRed
		deleteAction.image = UIImage(systemName: "trash")

		// set the swipe actions
		return UISwipeActionsConfiguration(actions: [deleteAction])
	}

}
