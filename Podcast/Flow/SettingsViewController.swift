//
//  SettingsViewController.swift
//  Podcast
//
//  Created on 10/15/21.
//  Copyright © 2021 TuneURL Inc. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

	@IBOutlet var autoDownloadSwitch: UISwitch!
	@IBOutlet var autoDeleteSwitch: UISwitch!
	@IBOutlet var searchSwitch: UISwitch!

	// MARK: - Actions

	@IBAction func searchCategoryChanged(_ sender: UISwitch) {
		isApplePodcast = sender.isOn
	}

}
