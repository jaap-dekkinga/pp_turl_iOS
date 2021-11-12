//
//  DownloadCache.swift
//  Podcast
//
//  Created by Gerrit Goossen <developer@gerrit.email> on 11/12/21.
//  Copyright © 2021 TuneURL Inc. All rights reserved.
//

import Alamofire
import Foundation

class DownloadCache {

	// static
	static var shared = DownloadCache()

	var downloads: [Download] = []

	// private
	private let downloadFolderURL: URL
	private let downloadIndexURL: URL

	// MARK: -

	init() {
		// create the download cache urls
		downloadFolderURL = AppDelegate.documentsURL.appendingPathComponent("Downloads/")
		downloadIndexURL = AppDelegate.documentsURL.appendingPathComponent("Downloads.plist")
		// load the download index
		loadDownloadIndex()
	}

	// MARK: -

	var userDownloads: [Episode] {
		var userDownloads = [Episode]()
		for download in downloads {
			if download.isUserDownload {
				userDownloads.append(download.episode)
			}
		}
		return userDownloads
	}

	// MARK: -

	func download(episode: Episode, completion: @escaping (Episode, Error?) -> Void, progress progressHandler: ((Double) -> Void)?) {
		// safety check
		guard (isDownloaded(episode: episode) == false) else {
			DispatchQueue.main.async {
				progressHandler?(1.0)
				completion(episode, nil)
			}
			return
		}

		// get the episode url
		guard let episodeURL = URL(string: episode.url ?? "") else {
			DispatchQueue.main.async {
				let error = NSError(domain: "Podcast", code: 100, userInfo: nil)
				completion(episode, error)
			}
			return
		}

		// get the download location
		let location = DownloadRequest.suggestedDownloadDestination()

		// start the download
		Alamofire.download(episodeURL, to: location).downloadProgress { (progress) in
			DispatchQueue.main.async {
				progressHandler?(progress.fractionCompleted)
			}
		}.response { (response) in
			var error: Error?
			// add the download to the downloads
			if let responseFileURL = response.destinationURL {
				// make sure the downloads folder exists
				let fileManager = FileManager.default
				_ = try? fileManager.createDirectory(at: self.downloadFolderURL, withIntermediateDirectories: true, attributes: nil)
				// move the file to the downloads folder
				let fileName = "\(UUID().uuidString).\(responseFileURL.pathExtension)"
				let fileURL = self.downloadFolderURL.appendingPathComponent(fileName)
				_ = try? fileManager.moveItem(at: responseFileURL, to: fileURL)
				// add the download to the index
				let download = Download(cacheFile: fileURL, episode: episode, isUserDownload: true)
				self.downloads.insert(download, at: 0)
				_ = self.saveDownloadIndex()
			} else {
				error = NSError(domain: "Podcast", code: 101, userInfo: nil)
			}
			// call the completion handler
			DispatchQueue.main.async {
				completion(episode, error)
			}
		}
	}

	func isDownloaded(episode: Episode) -> Bool {
		return (downloadIndex(for: episode) != nil)
	}

	func removeDownload(_ episode: Episode) {
		// get the download index
		guard let downloadIndex = downloadIndex(for: episode) else {
			return
		}

		// remove the cache file
		let download = downloads[downloadIndex]
		do {
			try FileManager.default.removeItem(at: download.cacheFile)
		} catch {
			NSLog("Error removing cache file. (\(error.localizedDescription))")
		}

		// update the downloads index
		downloads.remove(at: downloadIndex)
		_ = saveDownloadIndex()
	}

	// MARK: - Private

	private func downloadIndex(for episode: Episode) -> Int? {
		for index in 0 ..< downloads.count {
			let download = downloads[index]
			if (download.episode == episode) {
				return index
			}
		}
		return nil
	}

	private func loadDownloadIndex() {
		if let data = try? Data(contentsOf: downloadIndexURL),
		   let savedDownloads = try? PropertyListDecoder().decode([Download].self, from: data) {
			downloads = savedDownloads
		}
	}

	private func saveDownloadIndex() -> Bool {
		do {
			let data = try PropertyListEncoder().encode(downloads)
			try data.write(to: downloadIndexURL)
		} catch {
			NSLog("Error writing downloads index. (\(error.localizedDescription))")
			return false
		}
		return true
	}

	// MARK: -

	func generateAudioURL(from: String) -> URL? {
		if from.contains("file://") {
			if let url = URL(string: from) {
				if let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
					let fileName = url.lastPathComponent
					return path.appendingPathComponent(fileName)
				}
			}
		}
		return URL(string: from)
	}

}
