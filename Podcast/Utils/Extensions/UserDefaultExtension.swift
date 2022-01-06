//
//  UserDefaultExtension.swift
//  Podcast
//
//  Created on 10/14/21.
//  Copyright © 2021 TuneURL Inc. All rights reserved.
//

import Foundation

extension UserDefaults {

	// MARK: - Keys

	static let favoritesKey = "favoritesPodcastsKey"

	// MARK: -

	func addFavorite(podcast: Podcast) -> Bool {
		// safety check
		guard favorites.contains(where: { $0 == podcast }) == false else {
			return true
		}

		favorites.append(podcast)
		if !saveFavorites() {
			_ = favorites.dropLast()
			return false
		}

		return true
	}

	func removeFavorite(at index: Int) -> Bool {
		let removedPodcast = favorites.remove(at: index)
		if !saveFavorites() {
			favorites.insert(removedPodcast, at: index)
			return false
		}
		return true
	}

	func removeFavorite(podcast: Podcast) -> Bool {
		favorites.removeAll(where: { $0 == podcast })
		return saveFavorites()
	}

	// MARK: -

	func retrieveFavorites() {
		if let data = self.data(forKey: UserDefaults.favoritesKey) {
			do {
				favorites = try JSONDecoder().decode([Podcast].self, from: data)
			} catch let err {
				debugPrint("Retrieving Failed", err)
			}
		}
	}

	private func saveFavorites() -> Bool {
		do {
			let data = try JSONEncoder().encode(favorites)
			self.set(data, forKey: UserDefaults.favoritesKey)
		} catch let err {
			debugPrint("Saving Failed", err)
			return false
		}
		return true
	}

}
