//
//  BaseCollectionViewCell.swift
//  Podcast
//
//  Created on 10/14/21.
//  Copyright © 2021 TuneURL Inc. All rights reserved.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {

	override init(frame: CGRect) {
		super.init(frame: .zero)
		setup()
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func awakeFromNib() {
		super.awakeFromNib()
		setup()
	}

	func setup() {
		fatalError("setup() has not been implemented")
	}

}
