//
//  InterestViewController.swift
//  Podcast
//
//  Created on 11/16/21.
//  Copyright © 2021-2022 TuneURL Inc. All rights reserved.
//

import TuneURL
import UIKit

class InterestViewController: UIViewController, DMSwipeCardsViewDelegate {

	// public
	var userInteracted: Bool {
		get {
			return swipeView?.userInteracted ?? false
		}
	}

	// private
	private var swiped = false
	private var swipeView: DMSwipeCardsView<String>!
	private let tuneURL: TuneURL.Match

	private let greenYes = UIColor(red: (35.0 / 255.0), green: (188.0 / 255.0), blue: (73.0 / 255.0), alpha: 1.0)
	private let redNo = UIColor(red: (240.0 / 255.0), green: (83.0 / 255.0), blue: (73.0 / 255.0), alpha: 1.0)

	// MARK: -

	class func create(with tuneURL: TuneURL.Match, wasUserInitiated: Bool) -> InterestViewController {
		let viewController = InterestViewController(tuneURL: tuneURL)
		return viewController
	}

	// MARK: -

	init(tuneURL: TuneURL.Match) {
		self.tuneURL = tuneURL
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()

		//self.view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)

		let viewGenerator: (String, CGRect) -> (UIView) = {
			(element: String, frame: CGRect) -> (UIView) in

			let container = UIView(frame: CGRect(x: 0, y: 0, width: (frame.width), height: (frame.height)))
			container.backgroundColor = UIColor(red: 0.11, green: 0.48, blue: 0.53, alpha: 1.00)
			container.layer.cornerRadius = 20
			container.clipsToBounds = true

			let touchViewWidth: CGFloat = container.frame.width/2
			let touchViewHeight: CGFloat = touchViewWidth

			let leftView = UIView(frame: CGRect(x: (-touchViewWidth / 4.0), y: (container.frame.height / 2.0 - touchViewHeight / 2.0), width: touchViewWidth, height: touchViewHeight))
			leftView.backgroundColor = self.greenYes
			leftView.layer.cornerRadius = touchViewWidth/2
			container.addSubview(leftView)
			let leftLabelRect = CGRect(x: leftView.bounds.origin.x + touchViewWidth / 4.0, y: leftView.bounds.origin.y, width: leftView.bounds.width * 3.0 / 4.0, height: leftView.bounds.height)
			addLabel(in: leftView, text: "YES >", with: leftLabelRect)

			let rightView = UIView(frame: CGRect(x: container.frame.width - touchViewWidth + touchViewWidth / 4.0, y: container.frame.height / 2.0 - touchViewHeight / 2.0, width: touchViewWidth, height: touchViewHeight))
			rightView.backgroundColor = self.redNo
			rightView.layer.cornerRadius = touchViewWidth/2
			container.addSubview(rightView)
			let rightLabelRect = CGRect(x: rightView.bounds.origin.x, y: rightView.bounds.origin.y, width: rightView.bounds.width * 3.0 / 4.0, height: rightView.bounds.height)
			addLabel(in: rightView, text: "< NO", with: rightLabelRect)

			let labelHeight = CGFloat(100.0)
			let label = UILabel(frame: CGRect(x: container.bounds.origin.x, y: container.bounds.height - labelHeight, width: container.bounds.width, height: labelHeight))
			label.text = element
			label.textAlignment = .center
			label.textColor = UIColor.white.withAlphaComponent(0.7)
			label.font = UIFont.systemFont(ofSize: 26, weight: UIFont.Weight.thin)
			label.clipsToBounds = true
			label.layer.cornerRadius = 16
			label.adjustsFontSizeToFitWidth = true
			container.addSubview(label)

			container.layer.shadowRadius = 4
			container.layer.shadowOpacity = 1.0
			container.layer.shadowColor = UIColor(white: 0.9, alpha: 1.0).cgColor
			container.layer.shadowOffset = CGSize(width: 0, height: 0)
			container.layer.shouldRasterize = true
			container.layer.rasterizationScale = UIScreen.main.scale

			return container
		}

		func addLabel(in container: UIView, text: String, with rect: CGRect? = nil) {
			let rect = rect ?? container.bounds
			let label = UILabel(frame: rect)
			label.text = text
			label.textAlignment = .center
			label.font = UIFont.systemFont(ofSize: 32, weight: UIFont.Weight.thin)
			label.textColor = UIColor.white.withAlphaComponent(0.7)
			label.clipsToBounds = true
			label.adjustsFontSizeToFitWidth = true
			container.addSubview(label)
		}

		let overlayGenerator: (SwipeMode, CGRect) -> (UIView) = {
			(mode: SwipeMode, frame: CGRect) -> (UIView) in

			let label = UILabel()
			label.frame.size = CGSize(width: 100, height: 100)
			label.center = CGPoint(x: frame.width / 2, y: frame.height / 2)
			label.layer.cornerRadius = label.frame.width / 2
			label.backgroundColor = mode == .left ? self.redNo : self.greenYes
			label.clipsToBounds = true
			label.text = mode == .left ? "👎" : "👍"
			label.font = UIFont.systemFont(ofSize: 24)
			label.textAlignment = .center
			return label
		}

		let frame = CGRect(x: 0.0, y: 80.0, width: self.view.frame.width, height: self.view.frame.height - 160.0)
		swipeView = DMSwipeCardsView<String>(frame: frame, viewGenerator: viewGenerator, overlayGenerator: overlayGenerator)
		swipeView.delegate = self
		self.view.addSubview(swipeView)

		addCard()
	}

	// MARK: - Private

	private func addCard() {
		var actionMessage = "Interested? Swipe left or right."

		switch (tuneURL.type) {
			case "open_page":
				actionMessage = "Open \(tuneURL.info)?"
			case "save_page":
				actionMessage = "Save bookmark for \(tuneURL.info)?"
			default:
				break
		}

		swipeView.addCards([actionMessage], onTop: true)
	}

	// MARK: - DMSwipeCardsViewDelegate

	func swipedLeft(_ object: Any?) {
		// safety check
		guard (swiped == false) else {
			return
		}

		swiped = true

		self.view.backgroundColor = UIColor(red: (240.0 / 255.0), green: (83.0 / 255.0), blue: (73.0 / 255.0), alpha: 0.5)
	}

	func swipedRight(_ object: Any?) {
		// safety check
		guard (swiped == false) else {
			return
		}

		swiped = true

		self.view.backgroundColor = UIColor(red: (35.0 / 255.0), green: (188.0 / 255.0), blue: (73.0 / 255.0), alpha: 0.5)

		handleItem(tuneURL)
	}

	func cardTapped(_ object: Any?) {
	}

	func reachedEndOfStack() {
		self.dismiss(animated: true, completion: nil)
	}

	// MARK: - Private

	private func handleItem(_ tuneURL: TuneURL.Match, wasUserInitiated: Bool = false) {

		switch (tuneURL.type) {
/*
			case .coupon:
			case .phoneNumber:
				// open the phone number
				if let phoneURL = tuneURL.phoneURL {
					UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
				}
			case .poll:
				// open the poll - this shouldn't happen here because polls are the only action that displays automatically, everything else is controlled with this interested pop-up
//				if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//					appDelegate.openPoll(with: tuneURL, wasUserInitiated: wasUserInitiated)
//				}
*/
			case "open_page":
				// open web page
				if let itemURL = URL(string: tuneURL.info) {
					UIApplication.shared.open(itemURL, options: [:], completionHandler: nil)
				}

			case "save_page":
				// TODO: find out how this should work
				break

			default:
				break
		}
	}

}
