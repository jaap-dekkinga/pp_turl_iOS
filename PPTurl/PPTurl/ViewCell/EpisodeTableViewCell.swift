//
//  EpisodeTableViewCell.swift
//  PPTurl
//
//  Created by mac on 10/6/21.
//

import UIKit
import SDWebImage

class EpisodeTableViewCell: UITableViewCell {

    @IBOutlet var artImg: UIImageView!
    @IBOutlet var publishDate: UILabel!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var descLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func setEpisode(episode : Episode) {
        
        titleLbl.text = episode.title
        descLbl.text = episode.description
        publishDate.text = episode.published_at
        artImg.sd_setImage(with: URL(string: episode.artwork_url), completed: nil)
    }
}
