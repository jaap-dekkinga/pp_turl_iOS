//
//  HomeVC.swift
//  PPTurl
//
//  Created by mac on 10/6/21.
//

import UIKit

class HomeVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    
    var episodes : [Episode] = []
    @IBOutlet var episodesTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        loadEpisodes()
    }
    
    func loadEpisodes() {
        API.shared.getEpisodes { result, resultCnt in
            if (resultCnt > 0) {
                self.episodes = result
                self.episodesTable.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.episodes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "episode_cell") as! EpisodeTableViewCell
        let episode = self.episodes[indexPath.row]
        cell.setEpisode(episode: episode)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let download = UIContextualAction(style: .destructive, title: "Download") { (action, view, completion) in
            
            // Your Logic here
            completion(true)
        }
        
        let config = UISwipeActionsConfiguration(actions: [download])
        config.performsFirstActionWithFullSwipe = false
        return config
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
