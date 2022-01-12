//
//  BaseTableViewController.swift
//  Podcast
//
//  Created by Gerrit Goossen <developer@gerrit.email> on 1/11/22.
//  Copyright © 2022 TuneURL Inc. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController {

	// private
	private var insetsObserver: NSObjectProtocol?

	// MARK: - UIViewController

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		// udpate the content insets
		self.tableView.contentInset = Player.shared.additionalContentInsets
		self.tableView.scrollIndicatorInsets = Player.shared.additionalContentInsets
		// add a notification when the content insets should change
		insetsObserver = NotificationCenter.default.addObserver(forName: PlayerInsetsChangedNotification, object: nil, queue: nil) {
			_ in
			self.tableView.contentInset = Player.shared.additionalContentInsets
			self.tableView.scrollIndicatorInsets = Player.shared.additionalContentInsets
		}
	}

	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		if let observer = insetsObserver {
			NotificationCenter.default.removeObserver(observer)
			insetsObserver = nil
		}
	}

}
