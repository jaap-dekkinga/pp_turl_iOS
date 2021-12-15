//
//  GlobalData.swift
//  Podcast
//
//  Created on 10/14/21.
//  Copyright © 2021 TuneURL Inc. All rights reserved.
//

import Foundation

var favorites: [Podcast] = []

// MARK: -

func isFavorited(other: Podcast) -> Bool{
	for podcast in favorites {
		if podcast.isEqual(other) {
			return true
		}
	}
	return false
}
