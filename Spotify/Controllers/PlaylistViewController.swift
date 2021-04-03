//
//  PlaylistViewController.swift
//  Spotify
//
//  Created by user on 23/03/2021.
//

import UIKit

class PlaylistViewController: UIViewController, Dialog {
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
    private var audioTrackViewModels: [TrackCellViewModel] = []
    
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action,  target: self, action: #selector(didTapShare))
       
        view.addSubview(collectionView)
        view.addSubview(spinner)
        collectionView.register(TrackCollectionViewCell.self, forCellWithReuseIdentifier: TrackCollectionViewCell.identifier)
        collectionView.register(HeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCollectionReusableView.identifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    @objc private func didTapShare(){
        guard let url = URL(string: playlist.externalURLs["spotify"] ?? "") else {
            return
        }
        
        let vc = UIActivityViewController(
            activityItems: ["Check out the cool playlist on Spotify", url],
            applicationActivities: []
        )
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true, completion: nil)
    }
    
    private func fetchData(){
        spinner.startAnimating()
        ApiService.shared.getPlaylistDetail(playlist: playlist, completion: onDetailPlaylistFetched)
    }
    
    private func onDetailPlaylistFetched(result: Result<PlaylistDetailResponse, Error>){
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            
            switch result{
            case .success(let models):
                self.audioTracks = models.tracks.items.map({$0.track})
                self.audioTrackViewModels = models.tracks.items.compactMap({TrackCellViewModel(name: $0.track.name, artistName: $0.track.artists.first?.name ?? "", artworkURL: URL(string: $0.track.album?.images.first?.url ?? ""))})
                break
            case .failure(let error):
                self.present(self.showErrorDialog(message: error.localizedDescription), animated: true, completion: nil)
                break
            }
            self.collectionView.reloadData()
        }
    }
    
    static private func sectionLayout() -> NSCollectionLayoutSection {
        // Item
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 1.5, leading: 2.0, bottom: 1.5, trailing: 2.0)
        
        // Vertical Group in Horizontal Group
        let height: CGFloat = 70.0
      
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(height)), subitem: item, count: 1)
        
        // Section
        let layoutSection = NSCollectionLayoutSection(group: group)
        
        layoutSection.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        ]
        
        return layoutSection
    }

}

// MARK: CollectionView Methods

extension PlaylistViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: CollectionView Header
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCollectionReusableView.identifier, for: indexPath) as? HeaderCollectionReusableView, kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let viewModel = HeaderViewViewModel(name: playlist.name, description: playlist.description, ownerName: playlist.owner.displayName, artworkURL: URL(string: playlist.images.first?.url ?? ""))
        header.configure(viewModel: viewModel)
        header.delegate = self
        
       return header
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return audioTracks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackCollectionViewCell.identifier, for: indexPath) as! TrackCollectionViewCell
        
        let viewModel = audioTrackViewModels[indexPath.row]
        cell.configure(with: viewModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

//
extension PlaylistViewController: HeaderCollectionReusableViewDelegate {
    
    func PlaylistHeaderCollectionReusableViewDidTapPlayAll(_ header: HeaderCollectionReusableView) {
       // start playlist in queue
    }
}
