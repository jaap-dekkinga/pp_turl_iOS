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

	let maxCachedItems = 5
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

	var cachedItemCount: Int {
		var count = 0
		for download in downloads {
			if (download.isUserDownload == false) {
				count += 1
			}
		}
		return count
	}

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

	func cachedFile(for episode: Episode, completion: @escaping (URL?) -> Void) {

		// check if items should be removed from the cache first
		var cachedItemCount = self.cachedItemCount
		var currentIndex = (downloads.count - 1)
		while ((cachedItemCount > (maxCachedItems - 1)) && (currentIndex >= 0)) {
			let download = downloads[currentIndex]
			if (download.isUserDownload == false) {
				// remove a cache item
				removeDownload(index: currentIndex)
				cachedItemCount -= 1
			}
			currentIndex -= 1
		}

		// download and return the episode
		download(episode: episode, userDownloaded: false, progress: nil, completion: {
			(download, error) in
			DispatchQueue.main.async {
				var cacheFileURL: URL?
				if let cacheFileName = download?.cacheFileName {
					cacheFileURL = self.downloadFolderURL.appendingPathComponent(cacheFileName)
				}
				completion(cacheFileURL)
			}
		})
	}

	func download(episode: Episode, progress progressHandler: ((Double) -> Void)?, completion: @escaping (Episode, Error?) -> Void) {

		// check if a cached file already exists
		if let downloadIndex = downloadIndex(for: episode) {
			var download = downloads[downloadIndex]
			if (download.isUserDownload == false) {
				// convert the download to a user download
				download.isUserDownload = true
				downloads.remove(at: downloadIndex)
				downloads.insert(download, at: 0)
				_ = saveDownloadIndex()
			}
		}

		// download and return the episode
		download(episode: episode, userDownloaded: true, progress: progressHandler, completion: {
			(download, error) in
			DispatchQueue.main.async {
				completion(episode, error)
			}
		})
	}

	func isUserDownloaded(episode: Episode) -> Bool {
		if let downloadIndex = downloadIndex(for: episode) {
			return downloads[downloadIndex].isUserDownload
		}
		return false
	}

	func removeDownload(episode: Episode) {
		// get the download index
		guard let downloadIndex = downloadIndex(for: episode) else {
			return
		}

		// remove the download
		removeDownload(index: downloadIndex)
		_ = saveDownloadIndex()
	}

	// MARK: - Private

	private func download(episode: Episode, userDownloaded: Bool, progress progressHandler: ((Double) -> Void)?, completion: @escaping (Download?, Error?) -> Void) {

		// safety check
		if let downloadIndex = downloadIndex(for: episode) {
			let download = downloads[downloadIndex]
			completion(download, nil)
			return
		}

		// get the episode url
		guard let episodeURL = URL(string: episode.url ?? "") else {
			DispatchQueue.main.async {
				let error = NSError(domain: "Podcast", code: 100, userInfo: nil)
				completion(nil, error)
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
			var download: Download?
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
				download = Download(cacheFileName: fileName, episode: episode, isUserDownload: userDownloaded)
				self.downloads.insert(download!, at: 0)
				_ = self.saveDownloadIndex()
			} else {
				error = NSError(domain: "Podcast", code: 101, userInfo: nil)
			}
			// call the completion handler
			completion(download, error)
		}
	}

	private func downloadIndex(for episode: Episode) -> Int? {
		for index in 0 ..< downloads.count {
			let download = downloads[index]
			if (download.episode == episode) {
				return index
			}
		}
		return nil
	}

	private func removeDownload(index: Int) {
		// remove the cache file
		let download = downloads[index]
		do {
			let cacheFileURL = downloadFolderURL.appendingPathComponent(download.cacheFileName)
			try FileManager.default.removeItem(at: cacheFileURL)
		} catch {
			NSLog("Error removing cache file. (\(error.localizedDescription))")
		}

		// update the downloads index
		downloads.remove(at: index)
	}

	// MARK: -

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

}
