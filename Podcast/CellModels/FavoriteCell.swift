//
//  FavoriteCell.swift
//  Podcast
//
//  Created on 10/14/21.
//  Copyright © 2021 TuneURL Inc. All rights reserved.
//

import UIKit

class FavoriteCell: BaseCollectionViewCell {

	var podcast: Podcast? {
		didSet {
			if let podcast = podcast {
				titleLabel.text = podcast.trackName
				artistLabel.text = podcast.artistName
				favImage.downloadImage(url: podcast.largeArtwork)
			}
		}
	}

	lazy var favImage: UIImageView = {
		let imageView = UIImageView(image: #imageLiteral(resourceName: "blankPodcast"))
		imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1.0).isActive = true
		return imageView
	}()

	let titleLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.lineBreakMode = .byTruncatingTail
		label.textColor = .black
		label.font = .systemFont(ofSize: 15, weight: .semibold)
		return label
	}()

	let artistLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.numberOfLines = 2
		label.lineBreakMode = .byTruncatingTail
		label.textColor = UIColor.hotBlack.withAlphaComponent(0.75)
		label.font = .systemFont(ofSize: 12.25)
		return label
	}()

	lazy var stackView: UIStackView = {
		let stack = UIStackView(arrangedSubviews: [favImage, titleLabel, artistLabel])
		stack.axis = .vertical
		stack.distribution = .fill
		stack.spacing = 4
		stack.translatesAutoresizingMaskIntoConstraints = false
		return stack
	}()
	
	override func setup() {
		addSubview(stackView)
		stackView.fillSuperview()
	}

}
