import Foundation

// MARK: - Lists

var favorites: [Podcast] = []
var downloads: [Episode] = []
var isApplePodcast: Bool = true

// MARK: -

func isFavorited(other: Podcast) -> Bool{
    for podcast in favorites {
        if podcast.isEqual(other) {
            return true
        }
    }
    return false
}

func isDownloaded(other: Episode) -> Bool{
    for episode in downloads {
        if episode.isEqual(other) {
            return true
        }
    }
    return false
}
