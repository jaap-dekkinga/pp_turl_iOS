//
//  EpisodeCell.swift
//  Podcast
//
//  Created on 10/14/21.
//  Copyright © 2021 TuneURL Inc. All rights reserved.
//

import UIKit

class EpisodeCell: BaseTableViewCell {

	fileprivate let imageSize: CGFloat = 100
	fileprivate let roundRadius: CGFloat = 5.0

	var episode: Episode? {
		didSet {
			if let episode = episode {
				timeLabel.text = episode.date
				titleLabel.text = episode.title
				descriptionLabel.text = episode.description.sanitizeHTML()
				shouldDisable(episode.url == nil)
				if let imageURL = episode.artwork {
					episodeImage.downloadImage(url: imageURL)
				}
			}
		}
	}

	lazy var episodeImage: UIImageView = {
		let imageView = UIImageView(image: #imageLiteral(resourceName: "blankPodcast"))
		imageView.contentMode = .scaleAspectFill
		imageView.clipsToBounds = true
		imageView.layer.cornerRadius = roundRadius
		imageView.translatesAutoresizingMaskIntoConstraints = false
		return imageView
	}()

	let titleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = UIColor(named: "Item-Primary")
		label.numberOfLines = 2
		label.lineBreakMode = .byTruncatingTail
		label.font = .systemFont(ofSize: 14, weight: .bold)
		return label
	}()

	let timeLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textColor = UIColor(named: "Item-Secondary")
		label.font = .systemFont(ofSize: 13.5, weight: .semibold)
		return label
	}()

	let descriptionLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 3
		label.lineBreakMode = .byTruncatingTail
		label.textColor = UIColor(named: "Item-Tertiary")
		label.font = .systemFont(ofSize: 12.75)
		return label
	}()

	lazy var stackView: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [titleLabel, timeLabel, descriptionLabel])
		stack.axis = .vertical
		stack.distribution = .fill
		stack.spacing = 4
		stack.translatesAutoresizingMaskIntoConstraints = false
		return stack
	}()

	fileprivate func setupImageView() {
		addSubview(episodeImage)
		episodeImage.widthAnchor.constraint(equalToConstant: imageSize).isActive = true
		episodeImage.heightAnchor.constraint(equalToConstant: imageSize).isActive = true
		episodeImage.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
		episodeImage.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
		episodeImage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -15).isActive = true
	}

	fileprivate func setupStackView() {
		addSubview(stackView)
		centerY(item: stackView)
		stackView.leftAnchor.constraint(equalTo: episodeImage.rightAnchor, constant: 15).isActive = true
		stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -15).isActive = true
	}

	// MARK: -

	override func setup() {
		setupImageView()
		setupStackView()
	}

	override func setSelected(_ highlighted: Bool, animated: Bool) {
		super.setSelected(episode?.url != nil, animated: animated)
	}

	private func shouldDisable(_ disable: Bool) {
		var alpha: CGFloat = 1.0
		if disable {
			alpha = 0.5
		}
		episodeImage.alpha = alpha
		stackView.alpha = alpha
	}

}

