//
//  AudioTrackViewController.swift
//  Spotify
//
//  Created by user on 31/03/2021.
//

import UIKit

class AudioTrackViewController: UIViewController {
    let audioTrack: AudioTrack
    
    init(audioTrack: AudioTrack) {
        self.audioTrack = audioTrack
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = audioTrack.name
        view.backgroundColor = .systemBackground
    }

}
