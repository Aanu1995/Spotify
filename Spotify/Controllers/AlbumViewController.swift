//
//  AlbumViewController.swift
//  Spotify
//
//  Created by user on 31/03/2021.
//

import UIKit

class AlbumViewController: UIViewController, Dialog {
    private let album: Album
    
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
    private var audioTrackViewModels: [AlbumTrackCellViewModel] = []
    
    init(album: Album) {
        self.album = album
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchData()
    }
    
    private func configureUI(){
        title = album.name
        view.backgroundColor = .systemBackground
       
        view.addSubview(collectionView)
        view.addSubview(spinner)
        collectionView.register(AlbumTrackCollectionViewCell.self, forCellWithReuseIdentifier: AlbumTrackCollectionViewCell.identifier)
        collectionView.register(HeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderCollectionReusableView.identifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func fetchData(){
        spinner.startAnimating()
        ApiService.shared.getAlbumDetail(album: album, completion: onDetailAlbumFetched)
    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        spinner.center = view.center
    }
    
    private func onDetailAlbumFetched(result: Result<AlbumDetailResponse, Error>){
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            
            switch result{
            case .success(let models):
                self.audioTracks = models.tracks.items
                self.audioTrackViewModels = models.tracks.items.compactMap({AlbumTrackCellViewModel(name: $0.name, artistName: $0.artists.first?.name ?? "")})
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
        
        let viewModel = audioTrackViewModels[indexPath.row]
        cell.configure(with: viewModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension AlbumViewController: HeaderCollectionReusableViewDelegate {
    func PlaylistHeaderCollectionReusableViewDidTapPlayAll(_ header: HeaderCollectionReusableView) {
        //
    }
}
