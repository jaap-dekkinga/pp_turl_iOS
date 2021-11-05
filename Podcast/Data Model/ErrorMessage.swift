//
//  ErrorMessage.swift
//  Podcast
//
//  Created on 10/14/21.
//  Copyright © 2021 TuneURL Inc. All rights reserved.
//

import Foundation

enum ErrorMessage: String {
	case genericError = "Something went wrong."
	case favoriteFailed = "Something went wrong while trying to favorite this podcast."
	case removeFavoriteFailed = "Something went wrong while trying to remove this podcast from favorites."
	case downloadFailed = "Something went wrong while trying to dowload this episode."
	case removeDownloadFailed = "Something went wrong while trying to remove this episode from downloads."
}
