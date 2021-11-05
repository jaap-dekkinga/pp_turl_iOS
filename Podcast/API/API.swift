//
//  API.swift
//  Podcast
//
//  Created on 10/14/21.
//  Copyright © 2021 TuneURL Inc. All rights reserved.
//

import Foundation
import Alamofire
import FeedKit

class API {
	private let dataCache = NSCache<AnyObject, AnyObject>()
	//Singleton
	static let shared = API()

	public func searchPodcasts(searchText: String, completion: @escaping ([Podcast], Int) -> Void) {
		if let result = dataCache.object(forKey: searchText as AnyObject) as? [String: Any]{
			let (resultList, resultCount) = parseItunesResponse(result: result)
			completion(resultList, resultCount)
			return
		}

		let url = "https://itunes.apple.com/search"
		Alamofire.request(url, method: .get, parameters: ["term": searchText], encoding: URLEncoding.queryString, headers: nil).responseJSON {[unowned self] (response) in
			guard let result = response.value as? [String: Any] else {
				completion([], 0)
				return
			}
			self.dataCache.setObject(result as AnyObject, forKey: searchText as AnyObject)
			let (resultList, resultCount) = self.parseItunesResponse(result: result)
			completion(resultList, resultCount)
		}
	}

	public func getEpisodes(completion: @escaping ([BuzzsproutEpisode], Int) -> Void) {

		let url = "https://www.buzzsprout.com/api/1865534/episodes.json"
		let headers = [
			"Authorization": "Token token=135e81a09c9db21a3893046af8b3d080",
			"Accept": "application/json",
			"Content-Type": "application/json" ]
		Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.queryString, headers: headers).responseJSON {(response) in
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

	public func fetchEpisodesBuzz(completion: @escaping ([Episode], Int) -> Void) {

		let url = "https://www.buzzsprout.com/api/1865534/episodes.json"
		let headers = [
			"Authorization": "Token token=135e81a09c9db21a3893046af8b3d080",
			"Accept": "application/json",
			"Content-Type": "application/json" ]
		Alamofire.request(url, method: .get, parameters: nil, encoding: URLEncoding.queryString, headers: headers).responseJSON {(response) in
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

	public func fetchEpisodesFeed(urlString: String, completions: @escaping (RSSFeed?) -> Void) {
		if let result = dataCache.object(forKey: urlString as AnyObject) as? RSSFeed{
			completions(result)
			return
		}
		guard let url = URL(string: urlString) else { return }
		let parser = FeedParser(URL: url)
		parser.parseAsync {[unowned self] (res) in
			completions(res.rssFeed)
			if let feed = res.rssFeed {
				self.dataCache.setObject(feed as AnyObject, forKey: urlString as AnyObject)
			}
		}
	}

	public func clearCache() {
		dataCache.removeAllObjects()
	}

	public func downloadEpisode(episode: Episode, completion: @escaping (String) -> Void, progressTracker: @escaping (Double) -> Void) {
		let location = DownloadRequest.suggestedDownloadDestination()
		Alamofire.download(episode.url ?? "", to: location).downloadProgress { (progress) in
			DispatchQueue.main.async {
				progressTracker(progress.fractionCompleted)
			}
		}.response { (res) in
			let fileName = res.destinationURL?.absoluteString
			DispatchQueue.main.async {
				completion(fileName ?? episode.url ?? "")
			}
		}
	}

	private func parseItunesResponse(result: [String: Any]) -> ([Podcast], Int){
		guard let resultCount = result["resultCount"] as? Int else {
			return ([], 0)
		}

		if resultCount > 0 {
			if let results = result["results"] as? [[String: Any]] {
				var podcasts: [Podcast] = []
				var count = 0
				results.forEach { (item) in
					if let kind = item["kind"] as? String {
						if kind == "podcast" {
							count += 1
							podcasts.append(Podcast(data: item))
						}
					}
				}
				return (podcasts, count)
			}
		}
		return ([], 0)
	}
}
