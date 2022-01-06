//
//  EpisodesController.swift
//  Podcast
//
//  Created on 10/14/21.
//  Copyright © 2021 TuneURL Inc. All rights reserved.
//

import UIKit

class EpisodesController: UIViewController {

	var episodes: [Episode] = []

	fileprivate let cellId = "episodesCell"
	private let activity = UIActivityIndicatorView(style: .medium)
	private var downloadProgress: LoadingView!

	var podcast: Podcast? {
		didSet {
			if let podcast = podcast {
				navigationItem.title = podcast.title
				setupNavigationBarButtons(isFavorite: isFavorited(other: podcast))
				API.shared.getEpisodes(podcast: podcast) { [weak self] episodes in
					self?.episodes = episodes
					DispatchQueue.main.async { [weak self] in
						self?.tableView.reloadData()
						self?.removeLoader()
					}
				}
			}
		}
	}

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
		let emptyHeart = UIBarButtonItem(image: #imageLiteral(resourceName: "love"), style: .plain, target: self, action: #selector(addFavorite(_:)))
		emptyHeart.tintColor = UIColor(named: "Item-Primary")
		let filledHeart = UIBarButtonItem(image: #imageLiteral(resourceName: "love_sel"), style: .plain, target: self, action: #selector(removeFavorite(_:)))
		filledHeart.tintColor = UIColor(named: "Item-Favorite")
		navigationItem.rightBarButtonItem = isFavorite ? filledHeart : emptyHeart
	}

	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		setupTable()
		addLoader()
	}

	// MARK: - Actions

	@objc func addFavorite(_ sender: AnyObject?) {
		if UserDefaults.standard.addFavorite(podcast: podcast!) {
			setupNavigationBarButtons(isFavorite: true)
		}
	}

	@objc func removeFavorite(_ sender: AnyObject?) {
		if UserDefaults.standard.removeFavorite(podcast: podcast!) {
			setupNavigationBarButtons(isFavorite: false)
		}
	}

	// MARK: - Private

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
		cell.episode = episodes[indexPath.row]
		return cell
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let episode = episodes[indexPath.row]
		if episode.url == nil { return }
		Player.shared.playList = episodes
		Player.shared.currentPlaylistIndex = indexPath.row
		Player.shared.episodeImageURL = episode.artwork
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
		downloadAction.backgroundColor = UIColor(named: "optionGreen")
		return [downloadAction]
	}

}
