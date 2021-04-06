//
//  PlaybackPresenter.swift
//  Spotify
//
//  Created by user on 04/04/2021.
//

import UIKit
import AVFoundation

final class PlayerPresenter{
    static let shared = PlayerPresenter()
    
    private init(){}
    
    private var player: AVQueuePlayer?
    private var tracks: [AudioTrack] = []
    
    private var previousTracks: [AudioTrack] = []
    
    private var isAlbum: Bool = false
    
    private var albumURL: URL?
    
    private var viewController: PlayerViewController?
    
    private var currentTrack: AudioTrack? {
       if !tracks.isEmpty{
         return tracks.first
       }
        return nil
    }
    
    func startPlayback(from viewController: UIViewController, track: AudioTrack, isTrackFromAlbum: Bool = false, albumImageURL: URL? = nil){
        isAlbum = isTrackFromAlbum
        albumURL = albumImageURL
        self.tracks = [track]
       navigateToNextScreen(from: viewController)
    }
    
    func startPlayback(from viewController: UIViewController, tracks: [AudioTrack], isTracksFromAlbum: Bool = false, albumImageURL: URL? = nil){
       isAlbum = isTracksFromAlbum
       albumURL = albumImageURL
       self.tracks = tracks
       navigateToNextScreen(from: viewController)
    }
    
    private func navigateToNextScreen(from viewController: UIViewController){
        var avPlayerItems: [AVPlayerItem] = []
        var newAudioTracks: [AudioTrack] = []
        previousTracks = []
            
        for audioTrack in tracks {
            if let url = URL(string: audioTrack.previewURL ?? "") {
                avPlayerItems.append(AVPlayerItem(url: url))
                newAudioTracks.append(audioTrack)
            }
        }
        player = AVQueuePlayer(items: avPlayerItems)
        tracks = newAudioTracks
        player?.volume = getVolume()
        
        if !player!.items().isEmpty{
            let vc = PlayerViewController()
            vc.title = currentTrack?.name
            vc.dataSource = self
            vc.delegate = self
            
            self.viewController = vc
            viewController.present(UINavigationController(rootViewController:vc), animated: true) { [weak self] in
                self?.player?.play()
            }
        }
    }
    
    private func getVolume() -> Float{
        let volume = UserDefaults.standard.float(forKey: "volume")
        if  volume > 0.0 {
            return volume
        }else {
            return 0.5
        }
    }
}

extension PlayerPresenter : PlayerViewControllerDelegate, PlayerViewControllerDatasource {
    
    func PlayerViewControllerDelegateDidAdjustVolume(to value: Float) {
        player?.volume = value
        UserDefaults.standard.set(value, forKey: "volume")
    }
    
    func PlayerViewControllerDelegateDidTapForward() {
        if player!.items().count > 1{
            player?.pause()
            player?.advanceToNextItem()
            self.viewController?.refreshUI()
            let track = tracks.remove(at: 0)
            previousTracks.append(track)
            player?.play()
        }
    }
    
    func PlayerViewControllerDelegateDidTapBackward() {
        guard !previousTracks.isEmpty else {
            return
        }
        tracks.insert(previousTracks.last!, at: 0)
        previousTracks.remove(at: previousTracks.count - 1)
        player = AVQueuePlayer(items: tracks.compactMap({AVPlayerItem(url: URL(string: $0.previewURL ?? "")!)}))
        player?.volume = getVolume()
        self.viewController?.refreshUI()
        player?.play()
    }
    
    func PlayerViewControllerDelegateDidTapPlayPause() {
        if let player = player {
            if player.timeControlStatus == .playing {
                player.pause()
            } else {
                player.play()
            }
        }
    }
    
    var songName: String? {
        return currentTrack?.name
    }
    
    var subTitle: String? {
        return currentTrack?.artists.first?.name
    }
    
    var imageURL: URL? {
        if isAlbum {
            return albumURL
        }
        return URL(string: currentTrack?.album?.images.first?.url ?? "")
    }
}
