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
    
    private var currentTrack: AudioTrack? {
       if !tracks.isEmpty{
            return tracks.first
       }
        return nil
    }
    
    func startPlayback(from viewController: UIViewController, track: AudioTrack){
        self.tracks = [track]
       navigateToNextScreen(from: viewController)
    }
    
    func startPlayback(from viewController: UIViewController, tracks: [AudioTrack]){
        self.tracks = tracks
       navigateToNextScreen(from: viewController)
    }
    
    private func navigateToNextScreen(from viewController: UIViewController){
        var avPlayerItems: [AVPlayerItem] = []
            
        for audioTrack in tracks {
            if let url = URL(string: audioTrack.previewURL ?? "") {
                avPlayerItems.append(AVPlayerItem(url: url))
            }
        }
        player = AVQueuePlayer(items: avPlayerItems)
        player?.volume = 0.5
        
        if !player!.items().isEmpty{
            let vc = PlayerViewController()
            vc.title = currentTrack?.name
            vc.dataSource = self
            vc.delegate = self
            
            viewController.present(UINavigationController(rootViewController:vc), animated: true) { [weak self] in
                self?.player?.play()
            }
        }
    }
}

extension PlayerPresenter : PlayerViewControllerDelegate, PlayerViewControllerDatasource {
    
    func PlayerViewControllerDelegateDidAdjustVolume(to value: Float) {
        player?.volume = value
    }
    
    func PlayerViewControllerDelegateDidTapForward() {
        player?.pause()
        player?.advanceToNextItem()
        player?.play()
    }
    
    func PlayerViewControllerDelegateDidTapBackward() {
//        player?.pause()
//        AVQueuePlayer.
//        player?.play()
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
        return URL(string: currentTrack?.album?.images.first?.url ?? "")
    }
}
