//
//  Reporting.swift
//  Podcast
//
//  Created by Gerrit Goossen <developer@gerrit.email> on 1/6/22.
//  Copyright © 2022 TuneURL Inc. All rights reserved.
//

import Alamofire
import Foundation

class Reporting {

	// reporting actions
	enum Action: String {
		case started = "started"
		case disliked = "dislike"
		case liked = "liked"
		case loved = "loved"
		case bookmarked = "bookmarked"
		case shared = "shared"
	}

	// reporting server configuration
	private static let serverHost = "pnz3vadc52.execute-api.us-east-2.amazonaws.com"
	private static let serverPath = "/dev/createPodcastReport"

	// MARK: -

	class func report(playerItem: PlayerItem, action: Action, time: Double = 0.0) {
		// create the report data
		var reportData = [String : String]()
		reportData["action"] = action.rawValue
		reportData["title"] = playerItem.podcast.title
		reportData["artist"] = playerItem.podcast.author
		reportData["episode"] = playerItem.episode.title
		reportData["season"] = "none"
		reportData["UUID"] = AppDelegate.uniqueID
		reportData["timestamp"] = Float64(time).formatDuration()

		// create the server url
		guard let serverURL = URL(string: ("https://" + serverHost + serverPath)) else {
			return
		}

		// perform the request
		Alamofire.request(serverURL, method: .post, parameters: reportData).response {
			(response) in
#if DEBUG
			if let responseData = response.data,
			   let responseString = String(data: responseData, encoding: .utf8) {
				print("report response: \(responseString)")
			} else {
				print("report response: [error]")
			}
#endif // DEBUG
		}
	}

}
