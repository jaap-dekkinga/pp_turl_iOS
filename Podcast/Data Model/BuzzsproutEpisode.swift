//
//  BuzzsproutEpisode.swift
//  Podcast
//
//  Created on 10/14/21.
//  Copyright © 2021 TuneURL Inc. All rights reserved.
//

import Foundation

struct BuzzsproutEpisode: Codable {

	let id: Int
	let title: String
	let audio_url: String
	let artwork_url: String
	let description: String
	let artist: String
	let published_at: String
	let duration: Int
	let hq: Bool
	let magic_mastering: Bool
	let guid: String
	let custom_url: String
	let episode_number: Int
	let season_number: Int
	let explicit: Bool
	let private_val: Bool
	let total_plays: Int


	init(data: [String: Any]) {
		self.id = data["id"] as? Int ?? 0

		self.artist = data["artist"] as? String ?? "Unknown"
		self.title = data["title"] as? String ?? "No Title"
		self.audio_url = data["audio_url"] as? String ?? ""
		self.artwork_url = data["artwork_url"] as? String ?? ""
		self.description = data["description"] as? String ?? ""
		self.published_at = data["published_at"] as? String ?? ""
		self.guid = data["guid"] as? String ?? ""
		self.custom_url = data["custom_url"] as? String ?? ""

		self.duration = data["duration"] as? Int ?? 0
		self.episode_number = data["episode_number"] as? Int ?? 0
		self.season_number = data["season_number"] as? Int ?? 0
		self.total_plays = data["total_plays"] as? Int ?? 0

		self.hq = data["hq"] as? Bool ?? false
		self.magic_mastering = data["magic_mastering"] as? Bool ?? false
		self.explicit = data["explicit"] as? Bool ?? false
		self.private_val = data["private_val"] as? Bool ?? false
	}
}
