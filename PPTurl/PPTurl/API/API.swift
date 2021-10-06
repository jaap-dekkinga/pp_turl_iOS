import Foundation
import Alamofire
import FeedKit

class API {
    private let dataCache = NSCache<AnyObject, AnyObject>()
    //Singleton
    static let shared = API()
    
    public func getEpisodes(completion: @escaping ([Episode], Int) -> Void) {
    
        let url = "https://www.buzzsprout.com/api/1865534/episodes.json"
        let headers : HTTPHeaders =  [
                    "Authorization": "Token token=135e81a09c9db21a3893046af8b3d080",
                    "Accept": "application/json",
                    "Content-Type": "application/json"]
        
        AF.request(url, method: .get,headers: headers).responseJSON {(response) in
            
            guard let results = response.value as? [[String: Any]] else {
                completion([], 0)
                return
            }

            var episodes: [Episode] = []
            var count = 0
            results.forEach { (item) in
                count += 1
                episodes.append(Episode(data: item))
            }

            completion(episodes, count)
        }
    }
    
    public func downloadEpisode(episode: Episode, completion: @escaping (String) -> Void, progressTracker: @escaping (Double) -> Void) {
        
        let location = DownloadRequest.suggestedDownloadDestination()
        AF.download(episode.audio_url, to: location).downloadProgress {
            (progress) in
                DispatchQueue.main.async {
                   progressTracker(progress.fractionCompleted)
                }
            }.response { (res) in
                let fileName = res.fileURL?.absoluteString
                DispatchQueue.main.async {
                    completion(fileName ?? episode.audio_url)
                }
        }
    }
}
