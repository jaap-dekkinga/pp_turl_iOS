//
//  MainViewController.swift
//  Podcast
//
//  Created on 10/14/21.
//  Copyright © 2021 TuneURL Inc. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {

	public let player = Player.shared

	private var maximizedConstraint: NSLayoutConstraint!
	private var minimizedConstraint: NSLayoutConstraint!
	private var collapsedConstraint: NSLayoutConstraint!
	private var coverHeight: NSLayoutConstraint!

	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()
		addPlayer()
		UserDefaults.standard.retrieveFavorites()
	}

	// MARK: - Private

	fileprivate func addPlayer() {
		player.delegate = self
		player.translatesAutoresizingMaskIntoConstraints = false
		view.insertSubview(player, belowSubview: tabBar)
		player.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
		player.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
		player.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
		maximizedConstraint = player.topAnchor.constraint(equalTo: view.topAnchor)
		minimizedConstraint = player.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
		collapsedConstraint = player.topAnchor.constraint(equalTo: tabBar.bottomAnchor)
		collapsedConstraint.isActive = true
	}

}

// MARK: - Player Delegate

extension MainViewController: PlayerDelegate {

	func minimize() {
		collapsedConstraint.isActive = false
		maximizedConstraint.isActive = false
		minimizedConstraint.isActive = true
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
			[unowned self] in
			self.view.layoutIfNeeded()
			self.tabBar.transform = .identity
			self.player.miniPlayer.alpha = 1
			self.player.stackView.alpha = 0
			self.player.transform = .identity
		})
	}

	func maximize() {
		collapsedConstraint.isActive = false
		maximizedConstraint.isActive = true
		minimizedConstraint.isActive = false
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
			[unowned self] in
			self.view.layoutIfNeeded()
			self.tabBar.transform = CGAffineTransform(translationX: 0, y: 100)
			self.player.miniPlayer.alpha = 0
			self.player.stackView.alpha = 1
		})
	}

}
