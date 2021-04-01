//
//  AlbumViewController.swift
//  Spotify
//
//  Created by user on 31/03/2021.
//

import UIKit

class AlbumViewController: UIViewController {
    private let album: Album
    
    init(album: Album) {
        self.album = album
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        title = album.name
        view.backgroundColor = .systemBackground
        super.viewDidLoad()
        ApiService.shared.getAlbumDetail(album: album, completion: onDetailAlbumFetched)
    }
    
    private func onDetailAlbumFetched(result: Result<AlbumDetailResponse, Error>){
        switch result{
        case .success(let model):
            break
        case .failure(let error):
            print(error.localizedDescription)
        }
    }
    
}
