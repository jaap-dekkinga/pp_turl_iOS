//
//  DownloadsViewController.swift
//  Podcast
//
//  Created on 10/14/21.
//  Copyright © 2021-2022 TuneURL Inc. All rights reserved.
//

import UIKit

class DownloadsViewController: UIViewController {

	fileprivate let cellId = "DownloadsCell"

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

	// MARK: -

	override func viewDidLoad() {
		super.viewDidLoad()
		view.addSubview(tableView)
		tableView.fillSuperview()
	}

	@objc fileprivate func updateDownloads() {
		tableView.reloadData()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tableView.reloadData()
		self.navigationController?.tabBarItem.badgeValue = nil
	}

}

extension DownloadsViewController: UITableViewDelegate, UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return DownloadCache.shared.userDownloads.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
		let playerItem = DownloadCache.shared.userDownloads[indexPath.row]
		cell.episode = playerItem.episode
		return cell
	}

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

		return TextTableViewHeader(text: "You have not downloaded any podcasts.")
	}

	func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return (DownloadCache.shared.userDownloads.count == 0) ? 250 : 0
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let playerItem = DownloadCache.shared.userDownloads[indexPath.row]
		Player.shared.playList = DownloadCache.shared.userDownloads
		Player.shared.currentPlaylistIndex = indexPath.row
		Player.shared.setPlayerItem(playerItem)
		Player.shared.maximizePlayer()
	}

	func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let playerItem = DownloadCache.shared.userDownloads[indexPath.row]
		let downloadAction = UITableViewRowAction(style: .normal, title: "Delete") {[unowned self] (_, index) in

			let confirmation = OptionSheet(title: "Remove from Downloads!", message: "Are you sure that you want to remove \"\(playerItem.episode.title)\" from your downloads library. You will no longer have access to this podcast.")
			confirmation.addButton(image: #imageLiteral(resourceName: "delete"), title: "Remove Episode", color: UIColor(named: "optionRed")!) {
				[unowned self] in
				DownloadCache.shared.removeDownload(for: playerItem)
				tableView.deleteRows(at: [index], with: .automatic)
				presentConfirmation(image: #imageLiteral(resourceName: "tick"), message: "Episode Deleted")
			}
			confirmation.show()
		}
		downloadAction.backgroundColor = UIColor(named: "optionRed")
		return [downloadAction]
	}

}
