//
//  Episode.swift
//  Podcast
//
//  Created on 10/14/21.
//  Copyright © 2021 TuneURL Inc. All rights reserved.
//

import UIKit
import FeedKit

struct Episode: Codable {
	var title: String
	var description: String
	var date: String
	var url: String?
	var author: String
	var artwork: String?
	var artworkSmall: String?

	init(feed: RSSFeedItem) {
		self.title = feed.title ?? "No Title"
		self.description = feed.description ?? "No Description"
		self.date = feed.pubDate?.formatDate() ?? "Unknown"
		self.url = feed.enclosure?.attributes?.url
		self.author = feed.iTunes?.iTunesAuthor ?? "Unknown"
		self.artwork = feed.iTunes?.iTunesImage?.attributes?.href ?? ""
	}

	init(data: [String: Any]) {
		self.title = data["title"] as? String ?? "No Title"
		self.description = data["description"] as? String ?? ""

		let dateFormat = DateFormatter()
		dateFormat.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS-HH:mm"
		self.date = dateFormat.date(from: data["published_at"] as! String)?.formatDate() ?? "Unknown"
		//self.date = data["published_at"] as? String ?? ""
		self.author = data["artist"] as? String ?? "Unknown"
		self.url = data["audio_url"] as? String ?? ""
		self.artwork = data["artwork_url"] as? String ?? ""
	}

	func isEqual(_ object: Any?) -> Bool {
		guard let otherEpisode = object as? Episode else { return false }
		return otherEpisode.date == date && otherEpisode.title == title
	}
}
