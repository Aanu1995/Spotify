//
//  PlaylistViewController.swift
//  Spotify
//
//  Created by user on 23/03/2021.
//

import UIKit

class PlaylistViewController: UIViewController {
    private let playlist: Playlist
    
    init(playlist: Playlist) {
        self.playlist = playlist
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Properties
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { (_, _) -> NSCollectionLayoutSection? in
            return PlaylistViewController.sectionLayout()
        })
        )
        return collectionView
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private var audioTracks: [AudioTrack] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        spinner.center = view.center
    }
    
    private func configureUI(){
        title = playlist.name
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        view.addSubview(spinner)
        collectionView.register(RecommendedTrackCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func fetchData(){
        spinner.startAnimating()
        ApiService.shared.getPlaylistDetail(playlist: playlist, completion: onDetailPlaylistFetched)
    }
    
    private func onDetailPlaylistFetched(result: Result<PlaylistDetailResponse, Error>){
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            
            switch result{
            case .success(let model):
                self.audioTracks = model.tracks.items.map({$0.track})
                break
            case .failure(let error):
                print(error.localizedDescription)
            }
            self.collectionView.reloadData()
        }
    }
    
    static private func sectionLayout() -> NSCollectionLayoutSection {
        // Item
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 2.0, leading: 2.0, bottom: 2.0, trailing: 2.0)
        
        // Vertical Group in Horizontal Group
        let height: CGFloat = 80.0
      
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(height)), subitem: item, count: 1)
        
        // Section
        let layoutSection = NSCollectionLayoutSection(group: group)
        
        return layoutSection
    }

}

// MARK: CollectionView Methods

extension PlaylistViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return audioTracks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier, for: indexPath) as! RecommendedTrackCollectionViewCell
        
        let audioTrack = audioTracks[indexPath.row]
        let viewModel = RecommendationCellViewModel(name: audioTrack.name, artistName: audioTrack.artists.first?.name ?? "", artworkURL: URL(string: audioTrack.album?.images.first?.url ?? ""))
       // cell.configure(with: viewModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
