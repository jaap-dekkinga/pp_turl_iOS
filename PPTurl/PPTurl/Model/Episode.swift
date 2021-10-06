//
//  BuzzsproutEpisode.swift
//  Podcast
//
//  Created by mac on 10/6/21.
//  Copyright © 2021 Raghav Bhasin. All rights reserved.
//

import Foundation

struct Episode: Codable {
    
    let id: Int
    let title: String
    var audio_url: String
    var artwork_url: String
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
        
        self.artist = data["title"] as? String ?? "Unknown"
        self.title = data["title"] as? String ?? "No Title"
        self.audio_url = data["audio_url"] as? String ?? ""
        self.artwork_url = data["artwork_url"] as? String ?? ""
        self.description = data["description"] as? String ?? ""
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
        
        //Date Parsing
        let published = data["published_at"] as? String ?? ""
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.000Z"
        let date = dateFormatter.date(from: published)
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
        
        self.published_at = dateFormatter.string(from: date!)
    }
    
    func isEqual(_ object: Any?) -> Bool {
        guard let otherEpisode = object as? Episode else { return false }
        return otherEpisode.published_at == published_at && otherEpisode.title == title
    }
}
