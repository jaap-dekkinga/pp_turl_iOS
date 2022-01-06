//
//  Player.swift
//  Podcast
//
//  Created on 10/14/21.
//  Copyright © 2021-2022 TuneURL Inc. All rights reserved.
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

	enum Reaction {
		case dislike
		case like
		case love
	}

	// static
	static let shared = Player(nibName: "Player", bundle: nil)

	// constants
	let bookmarkRewindTime: Float64 = 10.0
	let reactionTime = 3.0	// seconds
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
	var currentStartTime = 0.0
	var delegate: PlayerDelegate!
	var fullPlayerConstraints = [NSLayoutConstraint]()
	var miniPlayerConstraints = [NSLayoutConstraint]()
	var playList = [PlayerItem]()
	var reactionResetTimer: Timer?
	var tuneURLs = [TuneURL.Match]()

	// private
	private var duration: Float64 = 0.0
	private let imageScaleDown: CGFloat = 0.75
	private weak var interestViewController: InterestViewController?
	private let player = AVPlayer()
	private var playerItem: PlayerItem?
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

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		resetReactions()
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

	private func resetView() {
		episodeImage.image = UIImage(named: "blankPodcast")
		playButton.setImage(UIImage(named: "Player-Pause"), for: .normal)
		miniPlayButton.setImage(UIImage(named: "Mini-Player-Pause"), for: .normal)
		currentTime.text = "00:00"
		totalTime.text = "--:--"
		progressSlider.setValue(0, animated: false)
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

	private func setupFullPlayer() {
		episodeImage.layer.cornerRadius = 12
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
			let seconds = current.seconds
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
		guard let playerItem = self.playerItem else {
			return
		}

		// get the podcast episode from the cache
		DownloadCache.shared.cachedFile(for: playerItem, completion: startPlaying)
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

		// skip to the start time
		if (currentStartTime != 0.0) {
			player.seek(to: CMTime(seconds: currentStartTime, preferredTimescale: Int32(NSEC_PER_SEC)))
		}

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
			playButton.setImage(UIImage(named: "Player-Pause"), for: .normal)
			enlargeImage()
			player.play()
			miniPlayButton.setImage(UIImage(named: "Mini-Player-Pause"), for: .normal)
		} else {
			playButton.setImage(UIImage(named: "Player-Play"), for: .normal)
			player.pause()
			contractImage()
			miniPlayButton.setImage(UIImage(named: "Mini-Player-Play"), for: .normal)
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

	@IBAction func rewind(_ sender: AnyObject?) {
		seekTo(delta: -10)
	}

	@IBAction func bookmark(_ sender: AnyObject?) {
		// safety check
		guard let playerItem = self.playerItem else {
			return
		}

		// add the bookmark
		var time = (player.currentTime().seconds - bookmarkRewindTime)
		time = max(time, 0.0)
		Bookmarks.shared.addBookmark(playerItem: playerItem, time: time)

		// report the bookmark was created
		Reporting.report(playerItem: playerItem, action: .bookmarked, time: time)
	}

	@IBAction func dislike(_ sender: AnyObject?) {
		reaction(.dislike)
	}

	@IBAction func fastForward(_ sender: AnyObject?) {
		seekTo(delta: 10)
	}

	@IBAction func like(_ sender: AnyObject?) {
		reaction(.like)
	}

	@IBAction func love(_ sender: AnyObject?) {
		reaction(.love)
	}

	// MARK: -

	@IBAction func changeTime(_ slider: UISlider) {
		let newProgress = slider.value
		let newValue = Float64(newProgress) * duration
		let newTime = CMTime(seconds: newValue, preferredTimescale: Int32(NSEC_PER_SEC))
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
			info?[MPMediaItemPropertyTitle] = self.playerItem?.episode.title
			info?[MPMediaItemPropertyArtist] = self.playerItem?.episode.author
			info?[MPMediaItemPropertyAlbumArtist] = self.playerItem?.episode.author
			info?[MPMediaItemPropertyPlaybackDuration] = self.duration
			let tempIv = UIImageView()
			tempIv.downloadImage(url: self.playerItem?.episode.artwork ?? "") { (image) in
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
		let ratio = Float(current / duration)
		progressSlider.setValue(ratio, animated: true)
	}

	@objc func maximizePlayer() {
		delegate.playerMaximize()
	}

	@objc fileprivate func playerStalled() {
		playButton.setImage(UIImage(named: "Player-Play"), for: .normal)
		contractImage()
	}

	// MARK: -

	func setPlayerItem(_ playerItem: PlayerItem, startTime: Double = 0.0) {
		// reset
		resetView()
		player.pause()

		// save the player item
		self.playerItem = playerItem
		self.currentStartTime = startTime

		// update the item details
		titleLabel.text = playerItem.episode.title
		authorLabel.text = playerItem.episode.author
		dateLabel.text = playerItem.episode.date
		miniTitleLabel.text = playerItem.episode.title
		miniAuthorLabel.text = playerItem.episode.author

		// update the episode artwork
		if let episodeImageURL = playerItem.episode.artwork {
			miniEpisodeImage.downloadImage(url: episodeImageURL)
			episodeImage.downloadImage(url: episodeImageURL)
		} else {
			miniEpisodeImage.image = UIImage(named: "blankPodcast")
			episodeImage.image = UIImage(named: "blankPodcast")
		}

		// reset the episode view animation
		episodeView.transform = CGAffineTransform(scaleX: imageScaleDown, y: imageScaleDown)

		// start playing
		startPlaying()
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
		miniEpisodeImage.layer.cornerRadius = 8

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
		// get the next player item
		currentPlaylistIndex += 1
		if currentPlaylistIndex >= playList.count {
			currentPlaylistIndex = 0
		}
		// set the new player item
		setPlayerItem(playList[currentPlaylistIndex])
	}

	fileprivate func previousTrack() {
		// get the previous player item
		currentPlaylistIndex -= 1
		if currentPlaylistIndex < 0 {
			currentPlaylistIndex = playList.count - 1
		}
		// set the new player item
		setPlayerItem(playList[currentPlaylistIndex])
	}

	// MARK: - Reactions

	private func reaction(_ type: Reaction) {
		// safety check
		guard let playerItem = self.playerItem,
			  reactionResetTimer == nil else {
			return
		}

		var action: Reporting.Action
		let time = player.currentTime().seconds

		// update the reaction buttons
		switch type {
			case .dislike:
				dislikeButton.setImage(UIImage(named: "Player-Dislike-Active"), for: .normal)
				dislikeButton.tintColor = UIColor(named: "Item-Active")
				dislikeButton.isUserInteractionEnabled = false
				action = .disliked
			case .like:
				likeButton.setImage(UIImage(named: "Player-Like-Active"), for: .normal)
				likeButton.tintColor = UIColor(named: "Item-Active")
				likeButton.isUserInteractionEnabled = false
				action = .liked
			case .love:
				loveButton.setImage(UIImage(named: "Player-Love-Active"), for: .normal)
				loveButton.tintColor = UIColor(named: "Item-Favorite")
				loveButton.isUserInteractionEnabled = false
				action = .loved
		}

		// report the reaction
		Reporting.report(playerItem: playerItem, action: action, time: time)

		// start the reaction reset timer
		reactionResetTimer = Timer.scheduledTimer(withTimeInterval: reactionTime, repeats: false) {
			[weak self] _ in
			self?.resetReactions()
		}
	}

	private func resetReactions() {
		// clear the react timer
		reactionResetTimer?.invalidate()
		reactionResetTimer = nil
		// reset the reaction buttons
		dislikeButton.setImage(UIImage(named: "Player-Dislike-Inactive"), for: .normal)
		dislikeButton.tintColor = UIColor(named: "Button-Disabled")
		dislikeButton.isUserInteractionEnabled = true
		likeButton.setImage(UIImage(named: "Player-Like-Inactive"), for: .normal)
		likeButton.tintColor = UIColor(named: "Button-Disabled")
		likeButton.isUserInteractionEnabled = true
		loveButton.setImage(UIImage(named: "Player-Love-Inactive"), for: .normal)
		loveButton.tintColor = UIColor(named: "Button-Disabled")
		loveButton.isUserInteractionEnabled = true
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
