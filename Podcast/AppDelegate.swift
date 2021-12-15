//
//  AppDelegate.swift
//  Podcast
//
//  Created on 10/14/21.
//  Copyright © 2021 TuneURL Inc. All rights reserved.
//

import UIKit
import AVFoundation
import TuneURL

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

	// static
	static var shared: AppDelegate = {
		UIApplication.shared.delegate as! AppDelegate
	}()

	static var documentsURL: URL = {
		// get the documents folder
		guard let url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
			return URL(fileURLWithPath: NSTemporaryDirectory())
		}
		return url
	}()

	// public
	var window: UIWindow?

	// MARK: -

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		setupTuneURLTrigger()
		setupAppearance()
		return true
	}

	func applicationDidReceiveMemoryWarning(_ application: UIApplication) {
		API.shared.clearCache()
	}

	// MARK: - Private

	private func setupAppearance() {
		UITabBar.appearance().tintColor = UIColor(named: "hotPurple")
		UITabBar.appearance().unselectedItemTintColor = .lightGray
		UINavigationBar.appearance().prefersLargeTitles = true
	}

	private func setupTuneURLTrigger() {
		guard let url = Bundle.main.url(forResource: "trigger", withExtension: "wav") else {
			return
		}

		Detector.setTrigger(url)
	}

}
