//
//  LibraryViewController.swift
//  Spotify
//
//  Created by user on 22/03/2021.
//

import UIKit

class LibraryViewController: UIViewController {
    // MARK: Properties
    
    private let playlistVC = LibraryPlaylistViewController()
    private let albumVC = LibraryAlbumViewController()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.backgroundColor = .purple
        return scrollView
    }()
    
    private let tabView: LibraryTabView = {
        let tabView = LibraryTabView()
        return tabView
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = CGRect(x: 0, y: view.safeAreaInsets.top + 50, width: view.width, height: view.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom - 60)
       tabView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: 200, height: 50.0)
        
        
        scrollView.contentSize = CGSize(width: scrollView.width * 2, height: scrollView.height)
        playlistVC.view.frame = CGRect(x: 0, y: 0, width: scrollView.width, height: scrollView.height)
        albumVC.view.frame = CGRect(x: scrollView.width, y: 0, width: scrollView.width, height: scrollView.height)
    }
    
    private func configureUI(){
        view.backgroundColor = .systemBackground
        view.addSubview(tabView)
        view.addSubview(scrollView)
        scrollView.delegate = self
        tabView.delegate = self
        addChildren()
    }
    
    private func addChildren(){
        addChild(playlistVC)
        scrollView.addSubview(playlistVC.view)
        playlistVC.didMove(toParent: self)
        
        addChild(albumVC)
        scrollView.addSubview(albumVC.view)
        albumVC.didMove(toParent: self)
    }

}

// MARK: ScrollView

extension LibraryViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset: CGFloat = ((scrollView.contentOffset.x * 200) / view.width) / 2
        tabView.updateLayoutOnScroll(offset: currentOffset)
    }
}

// MARK: LibraryTabView

extension LibraryViewController: LibraryTabViewDelegate {
    func LibraryTabViewDidTapItem(at state: IndicatorState) {
        switch state {
        case .Playlist:
            scrollView.setContentOffset(.zero, animated: true)
        case .Album:
            scrollView.setContentOffset(CGPoint(x: view.width, y: 0), animated: true)
        }
    }
}
