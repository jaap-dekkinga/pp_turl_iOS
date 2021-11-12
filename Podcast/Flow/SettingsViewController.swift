//
//  SettingsViewController.swift
//  Podcast
//
//  Created on 10/14/21.
//  Copyright © 2021 TuneURL Inc. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

	@IBOutlet var autoDownloadSwitch: UISwitch!
	@IBOutlet var autoDeleteSwitch: UISwitch!
	@IBOutlet var searchCategorySwitch: UISwitch!

	// MARK: - Actions

	@IBAction func autoDeleteChanged(_ sender: UISwitch) {
		// TODO: ...
	}

	@IBAction func autoDownloadChanged(_ sender: UISwitch) {
		// TODO: ...
	}

	@IBAction func searchCategoryChanged(_ sender: UISwitch) {
		isApplePodcast = sender.isOn
	}

}
