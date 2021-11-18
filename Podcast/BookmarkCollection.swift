//
//  Bookmarks.swift
//  Podcast
//
//  Created by Gerrit Goossen <developer@gerrit.email> on 11/17/21.
//  Copyright © 2021 TuneURL Inc. All rights reserved.
//

import Foundation
import TuneURL

class BookmarkCollection {

	// static
	static let changedNotification = NSNotification.Name("BookmarkCollectionChanged")
	static var shared = BookmarkCollection()

	// public
	var bookmarks = [Bookmark]()

	// private
	private let bookmarksFileURL: URL

	// MARK: -

	init() {
		// create the bookmarks file url
		bookmarksFileURL = AppDelegate.documentsURL.appendingPathComponent("Bookmarks.plist")
		// reload the bookmarks
		reloadBookmarks()
	}

	// MARK: - Public

	func addBookmark(for tuneURL: TuneURL.Match) {
		// create the new bookmark
		let bookmark = Bookmark(id: tuneURL.id, name: tuneURL.name, url: tuneURL.info)
		bookmarks.append(bookmark)

		// save the bookmarks file
		saveBookmarks()

		// post the update notification
		NotificationCenter.default.post(name: BookmarkCollection.changedNotification, object: nil)
	}

	func removeBookmark(at index: Int) {
		// safety check
		guard (index < bookmarks.count) else {
			return
		}

		// remove the bookmark
		bookmarks.remove(at: index)

		// save the bookmarks file
		saveBookmarks()

		// post the update notification
		NotificationCenter.default.post(name: BookmarkCollection.changedNotification, object: nil)
	}

	// MARK: - Private

	private func reloadBookmarks() {
		// load the bookmarks file
		guard let bookmarksData = try? Data(contentsOf: bookmarksFileURL) else {
			return
		}

		// decode the bookmarks
		let decoder = PropertyListDecoder()
		guard let decodedItems = try? decoder.decode([Bookmark].self, from: bookmarksData) else {
			NSLog("Bookmarks: Error reading bookmarks file.")
			return
		}

		// set the bookmarks
		bookmarks = decodedItems
	}

	private func saveBookmarks() {
		do {
			// save the bookmarks
			let encoder = PropertyListEncoder()
			let bookmarksData = try encoder.encode(bookmarks)
			try bookmarksData.write(to: bookmarksFileURL)
		} catch {
			NSLog("Bookmarks: Error writing bookmarks file. (\(error.localizedDescription))")
		}
	}

}
