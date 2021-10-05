import Foundation
import Alamofire
import FeedKit

class API {
    private let dataCache = NSCache<AnyObject, AnyObject>()
    //Singleton
    static let shared = API()
    
    public func getEpisodes(completion: @escaping ([BuzzsproutEpisode], Int) -> Void) {
    
        let url = "https://www.buzzsprout.com/api/1865534/episodes.json"
        let headers = [
                    "Authorization": "Token token=135e81a09c9db21a3893046af8b3d080",
                    "Accept": "application/json",
                    "Content-Type": "application/json"]
        
        Alamofire.request(url, method: .get, encoding: URLEncoding.queryString, headers: headers).responseJSON {(response) in
            guard let results = response.value as? [[String: Any]] else {
                completion([], 0)
                return
            }
            
            var episodes: [BuzzsproutEpisode] = []
            var count = 0
            results.forEach { (item) in
                count += 1
                episodes.append(BuzzsproutEpisode(data: item))
            }
        
            completion(episodes, count)
        }
    }
}
