//
//  Player.swift
//  Podcast
//
//  Created on 10/14/21.
//  Copyright © 2021 TuneURL Inc. All rights reserved.
//

import AVKit
import MediaPlayer
import TuneURL
import UIKit

protocol PlayerDelegate {
	func playerMaximize()
	func playerMinimize()
}

class Player: UIViewController {

	// static
	static let shared = Player(nibName: "Player", bundle: nil)

	// constants
	let timeToPresentTuneURL: Float = 10.0

	// interface
	@IBOutlet var fullPlayer: UIView!
	@IBOutlet var miniPlayer: UIView!

	// full player
	@IBOutlet weak var authorLabel: UILabel!
	@IBOutlet weak var backButton: UIButton!
	@IBOutlet weak var bookmarkButton: UIButton!
	@IBOutlet weak var currentTime: UILabel!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var dislikeButton: UIButton!
	@IBOutlet weak var dismissButton: UIButton!
	@IBOutlet weak var episodeImage: UIImageView!
	@IBOutlet weak var episodeView: UIView!
	@IBOutlet weak var forwardButton: UIButton!
	@IBOutlet weak var likeButton: UIButton!
	@IBOutlet weak var loveButton: UIButton!
	@IBOutlet weak var playButton: UIButton!
	@IBOutlet weak var progressSlider: UISlider!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var totalTime: UILabel!

	// mini player
	@IBOutlet weak var miniAuthorLabel: UILabel!
	@IBOutlet weak var miniEpisodeImage: UIImageView!
	@IBOutlet weak var miniForwardButton: UIButton!
	@IBOutlet weak var miniPlayButton: UIButton!
	@IBOutlet weak var miniTitleLabel: UILabel!

	// public
	var currentFileURL: URL?
	var currentPlaylistIndex = 0
	var delegate: PlayerDelegate!
	var fullPlayerConstraints = [NSLayoutConstraint]()
	var miniPlayerConstraints = [NSLayoutConstraint]()
	var playList = [Episode]()
	var tuneURLs = [TuneURL.Match]()

	var episode: Episode? {
		didSet {
			if let episode = episode {
				clearView()
				player.pause()
				titleLabel.text = episode.title
				authorLabel.text = episode.author
				dateLabel.text = episode.date
				miniTitleLabel.text = episode.title
				miniAuthorLabel.text = episode.author
				startPlaying()
			}
		}
	}

	var episodeImageURL: String? {
		didSet {
			if let episodeImageURL = episodeImageURL {
				miniEpisodeImage.downloadImage(url: episodeImageURL)
				episodeImage.downloadImage(url: episodeImageURL)
				episodeView.transform = CGAffineTransform(scaleX: imageScaleDown, y: imageScaleDown)
			}
		}
	}

	// private
	private var duration: Float64 = 0.0
	private let imageScaleDown: CGFloat = 0.75
	private weak var interestViewController: InterestViewController?
	private let player = AVPlayer()
	private let roundRadius: CGFloat = 5.0

	private var activeTuneURL: TuneURL.Match? {
		didSet {
			if ((activeTuneURL?.id ?? -1) != (oldValue?.id ?? -1)) {
				if (activeTuneURL != nil) {
					beginTuneURL()
				} else {
					endTuneURL()
				}
			}
		}
	}

	// MARK: - UIViewController

	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.translatesAutoresizingMaskIntoConstraints = false
		setup()
	}

	// MARK: - Full Player

	func showFullPlayer() {
		// get the content view from the visual effect view
		guard let contentView = (self.view as? UIVisualEffectView)?.contentView,
			  fullPlayer.superview == nil else {
				  return
			  }

		// add the full player view
		fullPlayer.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(fullPlayer)
		fullPlayerConstraints.append(fullPlayer.leftAnchor.constraint(equalTo: contentView.leftAnchor))
		fullPlayerConstraints.append(fullPlayer.rightAnchor.constraint(equalTo: contentView.rightAnchor))
		fullPlayerConstraints.append(fullPlayer.topAnchor.constraint(equalTo: contentView.topAnchor))
		fullPlayerConstraints.append(fullPlayer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor))

		// activate the constraints
		for constraint in fullPlayerConstraints {
			constraint.isActive = true
		}

		// show the full player view
		fullPlayer.alpha = 1
	}

	func hideFullPlayer() {
		// safety check
		guard fullPlayer.superview != nil else {
			return
		}

		for constraint in fullPlayerConstraints {
			constraint.isActive = false
		}
		fullPlayerConstraints.removeAll()

		fullPlayer.alpha = 0
		fullPlayer.removeFromSuperview()
	}

	// MARK: - Private

	private func clearView() {
		episodeImage.image = #imageLiteral(resourceName: "blankPodcast")
		playButton.setImage(#imageLiteral(resourceName: "pause").withRenderingMode(.alwaysTemplate), for: .normal)
		miniPlayButton.setImage(#imageLiteral(resourceName: "pause").withRenderingMode(.alwaysTemplate), for: .normal)
		currentTime.text = "00:00"
		totalTime.text = "--:--"
	}

	private func setupFullPlayer() {
		episodeImage.layer.cornerRadius = roundRadius
		fullPlayer.alpha = 0
		fullPlayer.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleMaximizedPan(_:))))
	}

	private func setupAudioPlayback() {
		// setup the audio session
		do {
			try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .allowAirPlay)
			try AVAudioSession.sharedInstance().setActive(true, options: AVAudioSession.SetActiveOptions.notifyOthersOnDeactivation)
		} catch {
			print("Error setting audio session. (\(error.localizedDescription))")
		}

		// setup the audio player periodic update
		let updateInterval = CMTimeMake(value: 1, timescale: 2)
		player.addPeriodicTimeObserver(forInterval: updateInterval, queue: .main) {
			[weak self] (current) in

			// safety check
			guard let self = self else {
				return
			}

			// update the interface
			let seconds = CMTimeGetSeconds(current)
			self.currentTime.text = seconds.formatDuration()
			self.updateProgressSlider(current: seconds)

			// update notification center
			MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seconds

			// update any active tuneurl
			let currentTime = Float(seconds)
			var currentTuneURL: TuneURL.Match?
			for tuneURL in self.tuneURLs {
				if (currentTime >= tuneURL.time) && (currentTime < (tuneURL.time + self.timeToPresentTuneURL)) {
					currentTuneURL = tuneURL
					break
				}
			}
			self.activeTuneURL = currentTuneURL
		}
	}

	private func setup() {
		fullPlayer.alpha = 0
		miniPlayer.alpha = 0

		setupFullPlayer()
		setupMiniPlayer()

		NotificationCenter.default.addObserver(self, selector: #selector(playerStalled), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: nil)
		setupAudioPlayback()
		let commandCenter = MPRemoteCommandCenter.shared()
		enableCommandCenter(commands: [
			commandCenter.togglePlayPauseCommand: play,
			commandCenter.nextTrackCommand: nextTrack,
			commandCenter.previousTrackCommand: previousTrack
		])
	}

	private func enableCommandCenter(commands: [MPRemoteCommand: () -> Void]) {
		UIApplication.shared.beginReceivingRemoteControlEvents()

		commands.forEach { (command, action) in
			command.isEnabled = true
			command.addTarget { (_) -> MPRemoteCommandHandlerStatus in
				action()
				return .success
			}
		}
	}

	private func startPlaying() {
		// safety check
		guard let episode = episode else {
			return
		}

		// get the podcast from the cache
		DownloadCache.shared.cachedFile(for: episode, completion: startPlaying)
	}

	private func startPlaying(_ fileURL: URL?) {
		// safety check
		guard let fileURL = fileURL else {
			return
		}

		// reset playback
		tuneURLs.removeAll()

		// set the current item
		let item = AVPlayerItem(url: fileURL)
		player.replaceCurrentItem(with: item)
		currentFileURL = fileURL

		// start playback
		player.play()
		playerBuffered()

		// process the podcast for tuneurls
		Detector.processAudio(for: fileURL) { [weak self] matches in
			if let self = self, (matches.count > 0),
			   (self.currentFileURL == fileURL) {
				DispatchQueue.main.async {
					// save the discovered tuneurls
					self.tuneURLs = matches
#if DEBUG
					print("Found \(matches.count) tuneurls in the podcast.")
#endif // DEBUG
				}
			}
		}
	}

	fileprivate func enlargeImage() {
		UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
			[unowned self] in
			self.episodeView.transform = .identity
		})
	}

	fileprivate func contractImage() {
		UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
			[unowned self] in
			self.episodeView.transform = CGAffineTransform(scaleX: self.imageScaleDown, y: self.imageScaleDown)
		})
	}

	@IBAction func minimizePlayer(_ sender: AnyObject?) {
		delegate.playerMinimize()
	}

	@IBAction func play() {
		if player.timeControlStatus == .paused {
			playButton.setImage(#imageLiteral(resourceName: "pause").withRenderingMode(.alwaysTemplate), for: .normal)
			enlargeImage()
			player.play()
			miniPlayButton.setImage(#imageLiteral(resourceName: "pause").withRenderingMode(.alwaysTemplate), for: .normal)
		} else {
			playButton.setImage(#imageLiteral(resourceName: "playButton").withRenderingMode(.alwaysTemplate), for: .normal)
			player.pause()
			contractImage()
			miniPlayButton.setImage(#imageLiteral(resourceName: "playButton").withRenderingMode(.alwaysTemplate), for: .normal)
		}
	}

	@objc fileprivate func handleMaximizedPan(_ gesture: UIPanGestureRecognizer) {
		if gesture.state == .changed {
			let translation = gesture.translation(in: self.view.superview)
			if translation.y < 0 { return }
			self.view.transform = CGAffineTransform(translationX: 0, y: translation.y)
//			self.fullPlayer.alpha = 1 + translation.y / 200
//			self.miniPlayer.alpha = -translation.y / 200
		} else if gesture.state == .ended {
			let translation = gesture.translation(in: self.view.superview)
			let velocity = gesture.velocity(in: self.view.superview)
			if translation.y > 200 || (velocity.y > 500 && translation.y < 200) {
				self.view.transform = .identity
				minimizePlayer(nil)
				return
			}

			UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
				self.view.transform = .identity
//				self.miniPlayer.alpha = 0
//				self.fullPlayer.alpha = 1
			})
		}
	}

	// MARK: -

	@IBAction func backward(_ sender: AnyObject?) {
		seekTo(delta: -10)
	}

	@IBAction func bookmarkTapped(_ sender: AnyObject?) {
		// TODO: implement bookmarks
		let bookmarkTime = player.currentTime().seconds
		print("bookmark: \(bookmarkTime)")
	}

	@IBAction func dislike(_ sender: AnyObject?) {
		dislikeButton.setImage(#imageLiteral(resourceName: "dislike_sel").withRenderingMode(.alwaysTemplate), for: .normal)
		dislikeButton.tintColor = UIColor(named: "Item-Active")
	}

	@IBAction func forward(_ sender: AnyObject?) {
		seekTo(delta: 10)
	}

	@IBAction func like(_ sender: AnyObject?) {
		likeButton.setImage(#imageLiteral(resourceName: "like_sel").withRenderingMode(.alwaysTemplate), for: .normal)
		likeButton.tintColor = UIColor(named: "Item-Active")
	}

	@IBAction func love(_ sender: AnyObject?) {
		loveButton.setImage(#imageLiteral(resourceName: "love_sel").withRenderingMode(.alwaysTemplate), for: .normal)
		loveButton.tintColor = UIColor(named: "Item-Favorite")
	}

	// MARK: -

	@IBAction func changeTime(_ slider: UISlider) {
		let newProgress = slider.value
		let newValue = Float64(newProgress) * duration
		let newTime = CMTimeMakeWithSeconds(newValue, preferredTimescale: Int32(NSEC_PER_SEC))
		player.seek(to: newTime)
	}

	fileprivate func seekTo(delta: Int64) {
		let seconds = CMTimeMake(value: delta, timescale: 1)
		let seekTime = CMTimeAdd(player.currentTime(), seconds)
		player.seek(to: seekTime)
	}

	fileprivate func playerBuffered() {
		let time = CMTimeMake(value: 1, timescale: 3)
		player.addBoundaryTimeObserver(forTimes: [NSValue(time: time)], queue: .main) { [unowned self] in

			self.duration = CMTimeGetSeconds((self.player.currentItem?.duration)!)
			self.totalTime.text = self.duration.formatDuration()
			self.enlargeImage()

			var info = MPNowPlayingInfoCenter.default().nowPlayingInfo
			if info == nil {
				info = [String : Any]()
			}
			info?[MPMediaItemPropertyTitle] = self.episode?.title
			info?[MPMediaItemPropertyArtist] = self.episode?.author
			info?[MPMediaItemPropertyAlbumArtist] = self.episode?.author
			info?[MPMediaItemPropertyPlaybackDuration] = self.duration
			let tempIv = UIImageView()
			tempIv.downloadImage(url: self.episode?.artwork ?? "") { (image) in
				if let image = image {
					let artwork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (_) -> UIImage in
						return image
					})
					info?[MPMediaItemPropertyArtwork] = artwork
					MPNowPlayingInfoCenter.default().nowPlayingInfo = info
				}
			}
		}
	}

	fileprivate func updateProgressSlider(current: Float64) {
		let ratio = current/duration
		progressSlider.setValue(Float(ratio), animated: true)
	}

	@objc func maximizePlayer() {
		delegate.playerMaximize()
	}

	@objc fileprivate func playerStalled() {
		playButton.setImage(#imageLiteral(resourceName: "playButton").withRenderingMode(.alwaysTemplate), for: .normal)
		contractImage()
	}

	// MARK: - Mini Player

	func showMiniPlayer(above tabBar: UITabBar) {
		// get the content view from the visual effect view
		guard let contentView = (self.view as? UIVisualEffectView)?.contentView,
			  miniPlayer.superview == nil else {
			return
		}

		// add the mini player view
		miniPlayer.translatesAutoresizingMaskIntoConstraints = false
		contentView.addSubview(miniPlayer)
		miniPlayerConstraints.append(miniPlayer.leftAnchor.constraint(equalTo: contentView.leftAnchor))
		miniPlayerConstraints.append(miniPlayer.rightAnchor.constraint(equalTo: contentView.rightAnchor))
		miniPlayerConstraints.append(miniPlayer.topAnchor.constraint(equalTo: contentView.topAnchor))
		miniPlayerConstraints.append(miniPlayer.bottomAnchor.constraint(equalTo: tabBar.topAnchor))

		// activate the constraints
		for constraint in miniPlayerConstraints {
			constraint.isActive = true
		}

		// show the mini player
		miniPlayer.alpha = 1
	}

	func hideMiniPlayer() {
		// safety check
		guard miniPlayer.superview != nil else {
			return
		}

		for constraint in miniPlayerConstraints {
			constraint.isActive = false
		}
		miniPlayerConstraints.removeAll()

		miniPlayer.alpha = 0
		miniPlayer.removeFromSuperview()
	}

	// MARK: -

	fileprivate func setupMiniPlayer() {
		miniEpisodeImage.layer.cornerRadius = roundRadius

		// add the gesture recognizers
		miniPlayer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(maximizePlayer)))
		miniPlayer.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleMinimizedPan(_:))))
	}

	@objc fileprivate func handleMinimizedPan(_ gesture: UIPanGestureRecognizer) {
		if gesture.state == .ended {
			let velocity = gesture.velocity(in: self.view.superview)
			if velocity.y < -500 {
				maximizePlayer()
				return
			}
		}
	}

	fileprivate func nextTrack() {
		currentPlaylistIndex += 1
		if currentPlaylistIndex >= playList.count {
			currentPlaylistIndex = 0
		}
		episode = playList[currentPlaylistIndex]
		episodeImageURL = episode?.artwork
	}

	fileprivate func previousTrack() {
		currentPlaylistIndex -= 1
		if currentPlaylistIndex < 0 {
			currentPlaylistIndex = playList.count - 1
		}
		episode = playList[currentPlaylistIndex]
		episodeImageURL = episode?.artwork
	}

	// MARK: - TuneURL support

	private func beginTuneURL() {
		// safety check
		guard let tuneURL = activeTuneURL,
			  (interestViewController == nil) else {
				  return
			  }

#if DEBUG
		print("TuneURL active:")
		print("\tname: \(activeTuneURL?.name ?? "")")
		print("\tdescription: \(activeTuneURL?.description ?? "")")
		print("\tid: \(activeTuneURL?.id ?? -1)")
		print("\tinfo: \(activeTuneURL?.info ?? "")")
		print("\tmatchPercentage: \(activeTuneURL?.matchPercentage ?? -1)")
		print("\ttime: \(activeTuneURL?.time ?? -1)")
		print("\ttype: \(activeTuneURL?.type ?? "")")
#endif // DEBUG

		// open the interest view controller
		let viewController = InterestViewController.create(with: tuneURL, wasUserInitiated: false)
		AppDelegate.shared.window?.rootViewController?.present(viewController, animated: true)
		interestViewController = viewController
	}

	private func endTuneURL() {
		// safety check
		guard let viewController = interestViewController else {
			return
		}

		// check if the user has interacted with the interest card
		if (viewController.userInteracted == false) {
			// close the tune url view
			interestViewController?.dismiss(animated: true, completion: nil)
			interestViewController = nil
		}
	}

}
