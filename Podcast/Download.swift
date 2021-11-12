//
//  Download.swift
//  Podcast
//
//  Created by Gerrit Goossen <developer@gerrit.email> on 11/12/21.
//  Copyright © 2021 TuneURL Inc. All rights reserved.
//

import Foundation

struct Download: Codable {

	var cacheFile: URL
	var episode: Episode
	var isUserDownload: Bool

}
