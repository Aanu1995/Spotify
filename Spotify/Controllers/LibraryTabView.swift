//
//  TabView.swift
//  Spotify
//
//  Created by user on 06/04/2021.
//

enum IndicatorState {
    case Playlist
    case Album
}

protocol LibraryTabViewDelegate: AnyObject {
    func LibraryTabViewDidTapItem(at state: IndicatorState);
}

import UIKit

class LibraryTabView: UIView {
    
    weak var delegate: LibraryTabViewDelegate?
    
    private let playlistButton: UIButton  = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.setTitle("Playlists", for: .normal)
        return button
    }()
    
    private let albumButton: UIButton  = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.setTitle("Albums", for: .normal)
        return button
    }()
    
    private let tabIndicator: UIView = {
        let tabIndicator = UIView()
        tabIndicator.backgroundColor = .systemGreen
        tabIndicator.layer.masksToBounds = true
        tabIndicator.layer.cornerRadius = 4
        return tabIndicator
    }()
    
    let tabIndicatorheight: CGFloat = 3
    var currentIndicatorState: IndicatorState = .Playlist
    
    // MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(playlistButton)
        addSubview(albumButton)
        addSubview(tabIndicator)
        
        playlistButton.addTarget(self, action: #selector(didTapPlaylist), for: .touchUpInside)
        albumButton.addTarget(self, action: #selector(didTapAlbum), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        clipsToBounds = true
        backgroundColor = .systemBackground
        let buttonWith = width * 0.5
        let tabItemHeight = height - tabIndicatorheight - 10
        
        playlistButton.frame = CGRect(x: 0, y: 0, width: buttonWith, height: tabItemHeight)
        albumButton.frame = CGRect(x: playlistButton.right, y: 0, width: buttonWith, height:tabItemHeight)
        tabIndicator.frame = CGRect(x: playlistButton.left, y: playlistButton.bottom + 3, width: playlistButton.width, height: tabIndicatorheight)
    }

    
    @objc private func didTapPlaylist(){
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.updateLayout(state: .Playlist)
            self?.delegate?.LibraryTabViewDidTapItem(at: .Playlist)
        }
    }
    
    @objc private func didTapAlbum(){
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.updateLayout(state: .Album)
            self?.delegate?.LibraryTabViewDidTapItem(at: .Album)
        }
    }
    
    private func updateLayout(state: IndicatorState){
        switch state {
        case .Playlist:
            tabIndicator.frame = CGRect(x: playlistButton.left, y: playlistButton.bottom + 3, width: playlistButton.width, height: tabIndicatorheight)
        case .Album:
            tabIndicator.frame = CGRect(x: albumButton.left, y: playlistButton.bottom + 3, width: albumButton.width, height: tabIndicatorheight)
        }
        currentIndicatorState = state
    }
    
    private func updateLayoutDidScroll(){
        if currentIndicatorState == .Playlist {
            tabIndicator.frame = CGRect(x: albumButton.left, y: playlistButton.bottom + 3, width: albumButton.width, height: tabIndicatorheight)
            currentIndicatorState = .Album
        } else {
            tabIndicator.frame = CGRect(x: playlistButton.left, y: playlistButton.bottom + 3, width: playlistButton.width, height: tabIndicatorheight)
            currentIndicatorState = .Playlist
        }
    }
    
    public func updateLayoutOnScroll(){
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.updateLayoutDidScroll()
        }
    }
}
