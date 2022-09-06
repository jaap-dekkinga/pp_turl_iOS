//
//  InterestViewController.swift
//  Podcast
//
//  Created by Gerrit Goossen <developer@gerrit.email> on 1/28/22.
//  Copyright © 2022 TuneURL Inc. All rights reserved.
//

import TuneURL
import UIKit
import WebKit

class InterestViewController: UIViewController {
let downloader = DownloadCache()
	// interface
	@IBOutlet weak var actionLabel: UILabel!
	@IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var primaryView: UIView!
    
    @IBOutlet weak var openWebsiteButton: UIButton!
    // public
    
	var userInteracted = false
    var next_mp3 = URL(string: "")
    var mp3_path = String()
    var mp3Playlist = [String]()


//
    @IBOutlet weak var countDownTimerLabel: UILabel!
    var data  = ["Next to Mae Muller", "Next to drummer", "Next to background singers"]

	// private
	private var tuneURL: TuneURL.Match?

	// MARK: -
    
    
   
	class func create(with tuneURL: TuneURL.Match, wasUserInitiated: Bool) -> InterestViewController {
		let storyboard = UIStoryboard(name: "TuneURL", bundle: nil)
		let viewController = storyboard.instantiateViewController(withIdentifier: "InterestViewController") as! InterestViewController
		viewController.tuneURL = tuneURL
		return viewController
	}

	// MARK: - UIViewController
   
    lazy var buttonStackView : UIStackView = {
        let stackview = UIStackView()
        stackview.translatesAutoresizingMaskIntoConstraints = false
        stackview.sizeToFit()
        stackview.axis = .vertical
        stackview.contentMode = .scaleAspectFit
        return stackview
    }()
    
    
    
    func setupView(){

      primaryView.addSubview(buttonStackView)
      NSLayoutConstraint.activate([
          buttonStackView.centerYAnchor.constraint(equalTo: primaryView.centerYAnchor),
          buttonStackView.centerXAnchor.constraint(equalTo: primaryView.centerXAnchor),
      ])
      }
    
    
    
    
    
    
    
	override func viewDidLoad() {
		super.viewDidLoad()
		webView.layer.cornerRadius = 16.0
		webView.layer.masksToBounds = true
		if let tuneURL = self.tuneURL {
			setupTuneURL(tuneURL)
		}
        setupView()
        primaryView.backgroundColor = UIColor(red: CGFloat(240.0/255.0), green: CGFloat(240.0/255.0), blue: CGFloat(240.0/255.0), alpha: CGFloat(1.0))
        primaryView.layer.cornerRadius = 7.5
	}

	// MARK: - Actions

	@IBAction func openWebsite(_ sender: AnyObject?) {
		performAction()
	}

	// MARK: - Private

	private func performAction() {
        
		// safety check
		guard let tuneURL = self.tuneURL else {
			return
		}
        

		switch (tuneURL.type){
            
     
            
			case "coupon":
				// TODO: save the coupon
				break

			case "open_page":
				// open web page
				if let itemURL = URL(string: tuneURL.info) {
					UIApplication.shared.open(itemURL, options: [:], completionHandler: nil)
				}

			case "phone":
				// TODO: open the phone number url
//				if let phoneURL = tuneURL.phoneURL {
//					UIApplication.shared.open(phoneURL, options: [:], completionHandler: nil)
//				}
				break

			case "poll":
				// TODO: add polls
				break

			case "sms":
				// TODO: open message panel
				break

			case "save_page":
				// TODO: find out how this should work
				break

			default:
				break
		}

		// close
//		self.dismiss(animated: true, completion: nil)
	}

    var count = 3
	private func setupTuneURL(_ tuneURL: TuneURL.Match) {

		// setup the action message
		var actionMessage = ""

		switch (tuneURL.type) {
        case "CYOA":
        
            actionMessage = "Choose Your Own Adventure"
            webView.isHidden = true
        countDownTimerLabel.isHidden = false
        next_mp3 = URL(string: tuneURL.info)
        openWebsiteButton.isHidden =  true
           API.shared.getCYOA(id: tuneURL.id){ [self] files in
               mp3Playlist = files as! [String]
              count = 3
               Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(InterestViewController.update), userInfo: nil, repeats: true)
            
               
            for i in 0...2 {
                let oneBtn : UIButton = {
                             let button = UIButton()
                             button.setTitle(data[i], for: .normal)
                              button.backgroundColor = UIColor(named: "Item-Active")
                             button.setTitleColor(UIColor.white, for: .normal)
                             //button.translatesAutoresizingMaskIntoConstraints = false
                             button.contentHorizontalAlignment = .center
                             button.contentVerticalAlignment = .center
                             button.titleLabel?.font = UIFont(name: "SpartanMB-Bold", size: UIScreen.main.bounds.height * 0.02463054187)
                             button.layer.cornerRadius = UIScreen.main.bounds.height * 0.006157635468
                             button.tag = i
                     
                    button.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
                             return button
                         }()
                self.buttonStackView.addArrangedSubview(oneBtn)
                self.buttonStackView.spacing = UIScreen.main.bounds.height * 0.04310344828
                oneBtn.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.6333333333).isActive = true
                oneBtn.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.06157635468).isActive = true
                }

          
        }
    
        case "cyoa":
        
            actionMessage = "Choose Your Own Adventure"
            webView.isHidden = true
        countDownTimerLabel.isHidden = false
        next_mp3 = URL(string: tuneURL.info)
        openWebsiteButton.isHidden =  true
           API.shared.getCYOA(id: tuneURL.id){ [self] files in
               mp3Playlist = files as! [String]
              count = 3
               Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(InterestViewController.update), userInfo: nil, repeats: true)
            
               
            for i in 0...2 {
                let oneBtn : UIButton = {
                             let button = UIButton()
                             button.setTitle(data[i], for: .normal)
                              button.backgroundColor = UIColor(named: "Item-Active")
                             button.setTitleColor(UIColor.white, for: .normal)
                             //button.translatesAutoresizingMaskIntoConstraints = false
                             button.contentHorizontalAlignment = .center
                             button.contentVerticalAlignment = .center
                             button.titleLabel?.font = UIFont(name: "SpartanMB-Bold", size: UIScreen.main.bounds.height * 0.02463054187)
                             button.layer.cornerRadius = UIScreen.main.bounds.height * 0.006157635468
                             button.tag = i
                     
                    button.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
                             return button
                         }()
                self.buttonStackView.addArrangedSubview(oneBtn)
                self.buttonStackView.spacing = UIScreen.main.bounds.height * 0.04310344828
                oneBtn.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.6333333333).isActive = true
                oneBtn.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height * 0.06157635468).isActive = true
                }

          
        }
           
         
			case "coupon":
            countDownTimerLabel.isHidden = true
				actionMessage = "Tap to Save Coupon"
				webView.isHidden = true

			case "open_page":
            countDownTimerLabel.isHidden = true
				actionMessage = "Tap to Open"
				if let url = URL(string: tuneURL.info) {
					webView.load(URLRequest(url: url))
				}

			case "phone":
            countDownTimerLabel.isHidden = true
				actionMessage = "Tap to Call Now"
				webView.isHidden = true

			case "poll":
            countDownTimerLabel.isHidden = true
				webView.isHidden = true
            

                    case "save_page":
				actionMessage = "Save bookmark for \(tuneURL.info)?"
				if let url = URL(string: tuneURL.info) {
					webView.load(URLRequest(url: url))
				}
            

			case "sms":
            countDownTimerLabel.isHidden = true
				actionMessage = "Tap to Message Now"
				webView.isHidden = true

			default:
				break
		}

		actionLabel.text = actionMessage
	}
    
    @objc func buttonAction(sender : UIButton!){
        next_mp3 = URL(string: mp3Playlist[sender.tag])
        mp3_path = mp3Playlist[sender.tag]
        self.dismiss(animated: true, completion: {

            Player.shared.next_mp3 = self.next_mp3
            Player.shared.mp3_path = self.mp3_path
            Player.shared.printNextUrl()
        })
            
        
    }

    @objc func update() {
        if(count > 0) {
            count = count - 1
            countDownTimerLabel.text = String(count)
            if count == 0
            {
            self.dismiss(animated: true, completion: {
                Player.shared.next_mp3 = self.next_mp3
                Player.shared.mp3_path = self.mp3_path
                Player.shared.printNextUrl()
            })
                
            }
        }
    }
}
