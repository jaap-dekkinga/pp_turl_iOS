//
//  EpisodesController.swift
//  Podcast
//
//  Created on 10/14/21.
//  Copyright © 2021 TuneURL Inc. All rights reserved.
//

import UIKit
import FeedKit

class EpisodesController: UIViewController {

	fileprivate let cellId = "episodesCell"
	private var downloadProgress:LoadingView!

	var podcast: Podcast? {
		didSet {
			if let podcast = podcast {
				navigationItem.title = podcast.trackName
				setupNavigationBarButtons(isFavorite: isFavorited(other: podcast))
				API.shared.fetchEpisodesFeed(urlString: podcast.feedUrl) {[weak self] (feed) in
					guard let feed = feed else { return }
					self?.episodes = []
					for item in feed.items ?? [] {
						var newEpisode = Episode(feed: item)
						newEpisode.artwork = podcast.largeArtwork
						newEpisode.artworkSmall = podcast.artwork
						self?.episodes.append(newEpisode)
					}
					DispatchQueue.main.async {[weak self] in
						self?.tableView.reloadData()
						self?.removeLoader()
					}
				}
			}
		}
	}

	var episodes: [Episode] = []
	private let activity = UIActivityIndicatorView(style: .medium)

	lazy var tableView: UITableView = {
		let table = UITableView()
		table.translatesAutoresizingMaskIntoConstraints = false
		table.showsVerticalScrollIndicator = true
		let footer = UIView()
		table.tableFooterView = footer
		table.delegate = self
		table.dataSource = self
		table.register(EpisodeCell.self, forCellReuseIdentifier: cellId)
		return table
	}()

	fileprivate func setupTable() {
		view.addSubview(tableView)
		tableView.fillSuperview()
	}

	fileprivate func addLoader() {
		view.addSubview(activity)
		activity.fillSuperview()
		activity.startAnimating()
	}

	fileprivate func removeLoader() {
		view.removeConstraints(activity.constraints)
		activity.removeFromSuperview()
	}

	fileprivate func setupNavigationBarButtons(isFavorite: Bool) {
		//Get Fav Button
		let fav = UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(favoritePodcast))
		fav.tintColor = .purple
		//Get Heart Icon
		let heartIcon = UIBarButtonItem(image: #imageLiteral(resourceName: "heart").withRenderingMode(.alwaysTemplate), style: .plain, target: nil, action: nil)
		heartIcon.tintColor = .purple
		navigationItem.rightBarButtonItem = isFavorite ? heartIcon: fav
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		setupTable()

		if (isApplePodcast) {
			addLoader()
		}
	}

	@objc fileprivate func favoritePodcast() {
		if UserDefaults.standard.addToFavorites(podcast: podcast!) {
			addedToFavorites()
		} else {
			showError(message: .favoriteFailed)
		}

	}

	fileprivate func addedToFavorites() {
		setupNavigationBarButtons(isFavorite: true)
		let main = UIApplication.shared.keyWindow?.rootViewController as! UITabBarController
		main.viewControllers?[0].tabBarItem.badgeValue = "new"
		presentConfirmation(image: #imageLiteral(resourceName: "tick"), message: "Podcast Favorited")
	}

	fileprivate func addedToDownloads() {
		downloadProgress.removeFromSuperview()
		let main = UIApplication.shared.keyWindow?.rootViewController as! UITabBarController
		main.viewControllers?[2].tabBarItem.badgeValue = "new"
		presentConfirmation(image: #imageLiteral(resourceName: "downloadAction"), message: "Episode Downloaded")
	}
}

// MARK: - Search Table DataSource and Delegate
extension EpisodesController: UITableViewDelegate, UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return episodes.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
		cell.imageUrl = podcast?.artwork
		cell.episode = episodes[indexPath.row]
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let episode = episodes[indexPath.row]
		if episode.url == nil { return }
		Player.shared.playList = episodes
		Player.shared.currentPlaying = indexPath.row
		Player.shared.episodeImageURL = podcast?.largeArtwork
		Player.shared.episode = episode
		Player.shared.maximizePlayer()
	}

	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let episode = self.episodes[indexPath.row]
		downloadProgress = LoadingView()
		if DownloadCache.shared.isUserDownloaded(episode: episode) {
			let downloadAction =
			UITableViewRowAction(style: .normal, title: "Download") {
				(_,_) in
				//Do Nothing Already Downloaded
			}
			return [downloadAction]
		}
		let downloadAction = UITableViewRowAction(style: .normal, title: "Download") { [unowned self] (_, _) in
			UIApplication.shared.addSubview(view: self.downloadProgress)
			DownloadCache.shared.download(episode: episode, progress: {
				(completed) in
				self.downloadProgress.setPercentage(value: completed * 100)
			}, completion: {
				[weak self] (episode, error) in

				if (error == nil) {
					self?.addedToDownloads()
				} else {
					self?.showError(message: .downloadFailed)
				}
			})
		}
		downloadAction.backgroundColor = .optionGreen
		return [downloadAction]
	}

}
