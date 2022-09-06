//
//  CYOAItem.swift
//  Podcast
//
//  Created by Osama's Macbook on 04/09/2022.
//  Copyright © 2022 TuneURL Inc. All rights reserved.
//

import Foundation

// MARK: - WelcomeElement
import Foundation

// MARK: - Welcome
struct CYOAElement: Codable {
    let data: [Datum]
}

// MARK: - Datum
struct Datum: Codable {
    let tuneurlID, options: String
    let mp3URL: String

    enum CodingKeys: String, CodingKey {
        case tuneurlID = "tuneurl_id"
        case options
        case mp3URL = "mp3_url"
    }
}




//struct CYOAElement: Codable {
//    let tuneurlID, options: String
//    let mp3URL: String
//
////    enum CodingKeys: String, CodingKey {
////        case tuneurlID = "tuneurl_id"
////        case options
////        case mp3URL = "mp3_url"
////    }
//
//    init(json: [String : Any]) {
//        self.tuneurlID =  json["tuneurl_id"] as? String ?? ""
//        self.options =  json["options"] as? String ?? ""
//        self.mp3URL =  json["mp3_url"] as? String ?? ""
//    }
//
//    init?(item: RSSFeedItem) {
//        self.tuneurlID = item.tuneurlID ?? ""
//        self.options = item.options ?? ""
//        self.mp3URL = item.mp3URL ?? ""
//    }
//
//}
