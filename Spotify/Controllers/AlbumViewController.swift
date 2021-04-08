//
//  AlbumViewController.swift
//  Spotify
//
//  Created by user on 31/03/2021.
//

import UIKit

class AlbumViewController: UIViewController, Dialog {
    private let album: Album
  
    init(album: Album) {
        self.album = album
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Properties
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { (_, _) -> NSCollectionLayoutSection? in
            return AlbumViewController.sectionLayout()
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        spinner.center = view.center
    }
    
    // MARK: Methods
    
    private func configureUI(){
        title = album.name
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapAction))
       
        view.addSubview(collectionView)
        view.addSubview(spinner)
        collectionView.register(AlbumTrackCollectionViewCell.self, forCellWithReuseIdentifier: AlbumTrackCollectionViewCell.identifier)
        collectionView.register(HeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCollectionReusableView.identifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    @objc func didTapAction(){
        let actionVC = UIAlertController(title: album.name, message: "Actions", preferredStyle: .actionSheet)
        actionVC.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        actionVC.addAction(UIAlertAction(title: "Save Album", style: .default, handler: { [weak self] _ in
            guard let strongSelf = self else { return }
            ApiService.shared.saveAlbum(album: strongSelf.album) {success in
                DispatchQueue.main.async {
                    if success{
                        NotificationCenter.default.post(name: .albumSaveNotification, object: nil)
                    } else {
                        strongSelf.present(strongSelf.showErrorDialog(message: "Could not save the album"), animated: true)
                    }
                }
            }
        }))
        present(actionVC, animated: true)
    }
    
    private func fetchData(){
        spinner.startAnimating()
        ApiService.shared.getAlbumDetail(album: album, completion: onDetailAlbumFetched)
    }
    
    private func onDetailAlbumFetched(result: Result<AlbumDetailResponse, Error>){
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            
            switch result{
            case .success(let model):
                self.audioTracks = model.tracks.items
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
    
}


// MARK: CollectionView Methods

extension AlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    // MARK: CollectionView Header
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCollectionReusableView.identifier, for: indexPath) as? HeaderCollectionReusableView, kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let viewModel = HeaderViewViewModel(name: album.name, description: "Release Date: \(String.formatDate(string: album.releaseDate))", ownerName: album.artists.first?.name ?? "", artworkURL: URL(string: album.images.first?.url ?? ""))
        header.configure(viewModel: viewModel)
        header.delegate = self

       return header
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return audioTracks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumTrackCollectionViewCell.identifier, for: indexPath) as! AlbumTrackCollectionViewCell
        
        let track = audioTracks[indexPath.row]
        let viewModel = AlbumTrackCellViewModel(name: track.name, artistName: track.artists.first?.name ?? "")
        cell.configure(with: viewModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let track = audioTracks[indexPath.row]
        collectionView.deselectItem(at: indexPath, animated: true)
        PlayerPresenter.shared.startPlayback(from: self, track: track, isTrackFromAlbum: true, albumImageURL: URL(string: album.images.first?.url ?? ""))
    }
}

extension AlbumViewController: HeaderCollectionReusableViewDelegate {
    func playlistHeaderCollectionReusableViewDidTapPlayAll(_ header: HeaderCollectionReusableView) {
        PlayerPresenter.shared.startPlayback(from: self, tracks: audioTracks, isTracksFromAlbum: true, albumImageURL: URL(string: album.images.first?.url ?? ""))
    }
}
