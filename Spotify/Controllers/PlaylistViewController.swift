//
//  PlaylistViewController.swift
//  Spotify
//
//  Created by user on 23/03/2021.
//

import UIKit

class PlaylistViewController: UIViewController, Dialog {
    
    private let playlist: Playlist
    private let isOwner: Bool
    
    init(playlist: Playlist, isOwner: Bool = false) {
        self.playlist = playlist
        self.isOwner = isOwner
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
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchData()
        addLongPressGesture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        spinner.center = CGPoint(x: view.center.x, y: view.width + (view.height - view.width)/2)
    }
    
    // MARK: Methods
    
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
    
    private func addLongPressGesture(){
        if isOwner{
            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressed(gesture:)))
            collectionView.addGestureRecognizer(gesture)
        }
    }
    
    @objc func onLongPressed(gesture: UILongPressGestureRecognizer){
        let torchPoint = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: torchPoint) else { return }
        let track = audioTracks[indexPath.row]
        let vc = UIAlertController(title: track.name, message: "Are you sure you want to remove the track from the playlist?", preferredStyle: .actionSheet)
        
        vc.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        vc.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: { [weak self] _ in
            guard let strongSelf = self else { return }
            
            ApiService.shared.removeTrackFromPlaylist(playlistId: self!.playlist.id, track: track) { success in
                DispatchQueue.main.async {
                    if success {
                        strongSelf.audioTracks.remove(at: indexPath.row)
                        strongSelf.collectionView.deleteItems(at: [indexPath])
                    }else {
                        strongSelf.present(strongSelf.showErrorDialog(message:  "Could not remove track from playlist"), animated: true)
                       
                    }
                }
            }
        }))
        present(vc, animated: true)
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
                self.present(self.showErrorDialog(message: error.localizedDescription), animated: true)
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
    
    @objc private func didTapShare(){
        guard let url = URL(string: playlist.externalURLs["spotify"] ?? "") else {
            return
        }
        
        let vc = UIActivityViewController(
            activityItems: ["Check out the cool playlist on Spotify", url],
            applicationActivities: []
        )
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
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
        
        let audioTrack = audioTracks[indexPath.row]
        let viewModel = TrackCellViewModel(name: audioTrack.name, artistName: audioTrack.artists.first?.name ?? "", artworkURL: URL(string: audioTrack.album?.images.first?.url ?? ""))
        
        cell.configure(with: viewModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        HapticManager.shared.vibrateForSelection()
        collectionView.deselectItem(at: indexPath, animated: true)
        let track = audioTracks[indexPath.row]
        PlayerPresenter.shared.startPlayback(from: self, track: track)
    }
    
    
}

//
extension PlaylistViewController: HeaderCollectionReusableViewDelegate {
    
    func playlistHeaderCollectionReusableViewDidTapPlayAll(_ header: HeaderCollectionReusableView) {
        PlayerPresenter.shared.startPlayback(from: self, tracks: audioTracks)
    }
}
