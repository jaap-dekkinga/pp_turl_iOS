import Foundation

extension UserDefaults {
    //MARK:- Keys
    static let favoritesKey = "favoritesPodcastsKey"
    static let downloadsKey = "downloadsPodcastsKey"
    
    //MARK:- Remove element functions
    func removeFavoriteAt(index: Int) -> Bool {
        let removedPodcast = favorites.remove(at: index)
        if !saveFavorites() {
            favorites.insert(removedPodcast, at: index)
            return false
        }
        return true
    }
    
    func removeDownloadAt(index: Int) -> Bool {
        let removedEpisode = downloads.remove(at: index)
        if !saveDownloads() {
            downloads.insert(removedEpisode, at: index)
            return false
        }
        return true
    }
    
    //MARK:- Add element functions
    func addToFavorites(podcast: Podcast) -> Bool{
        favorites.append(podcast)
        if !saveFavorites() {
            _ = favorites.dropLast()
            return false
        }
        return true
    }
    
    func addToDownloads(episode: Episode) -> Bool{
        downloads.insert(episode, at: 0)
        if !saveDownloads() {
            _ = downloads.dropFirst()
            return false
        }
        return true
    }

    //MARK:- Retrieve List functions
    func retrieveFavorites() {
        if let data = self.data(forKey: UserDefaults.favoritesKey) {
            do {
                favorites = try JSONDecoder().decode([Podcast].self, from: data)
            } catch let err {
                debugPrint("Retrieving Failed", err)
            }
        }
    }
    
    func retrieveDownloads() {
        if let data = self.data(forKey: UserDefaults.downloadsKey) {
            do {
                downloads = try JSONDecoder().decode([Episode].self, from: data)
            } catch let err {
                debugPrint("Retrieving Failed", err)
            }
        }
    }
    
    //MARK:- Save List functions
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
    
    private func saveDownloads() -> Bool {
        do {
            let data = try JSONEncoder().encode(downloads)
            self.set(data, forKey: UserDefaults.downloadsKey)
        } catch let err {
            debugPrint("Saving Failed", err)
            return false
        }
        return true
    }
    
}
