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
    }
    
    init(data: [String: Any]) {
        self.title = data["title"] as? String ?? "No Title"
        self.description = data["description"] as? String ?? ""
        self.date = data["published_at"] as? String ?? ""
        self.author = data["artist"] as? String ?? "Unknown"
        self.url = data["audio_url"] as? String ?? ""
        self.artwork = data["artwork_url"] as? String ?? ""
    }
    
    func isEqual(_ object: Any?) -> Bool {
        guard let otherEpisode = object as? Episode else { return false }
        return otherEpisode.date == date && otherEpisode.title == title
    }
}
