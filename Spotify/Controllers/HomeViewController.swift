//
//  ViewController.swift
//  Spotify
//
//  Created by user on 22/03/2021.
//

import UIKit

class HomeViewController: UIViewController, Dialog {
    
    // MARK: Properties
    
    private var collectionView: UICollectionView = {
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout { (section, _ ) -> NSCollectionLayoutSection? in
            return HomeViewController.createSectionLayout(section: section)
          }
        )
        return collectionView
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private var sections: [BrowseSectionType] = []
    private var albums: [Album] = []
    private var playlists: [Playlist] = []
    private var audioTracks: [AudioTrack] = []
    
       
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureCollectionView()
        fetchData()
        addGestureRecognizer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        spinner.center = view.center
    }
    
    // MARK: Methods
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .done, target: self, action: #selector(didTapSettings))
    }
    
    // when track is long pressed should open the action sheet to ask if they want to add track
    private func addGestureRecognizer() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        collectionView.addGestureRecognizer(gesture)
    }
    
    @objc func didLongPress(_ gesture: UILongPressGestureRecognizer){
        guard gesture.state == .began else { return }
        
        let torchPoint = gesture.location(in: collectionView)
        guard let indexPath = collectionView.indexPathForItem(at: torchPoint), indexPath.section == 2 else {
            return
        }
        
        let track = audioTracks[indexPath.row]
        let actionSheet = UIAlertController(title: track.name, message: "Would you like to add this to a playlist?", preferredStyle: .actionSheet)
        // Cancel action button
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        // add to Playlist action button
        actionSheet.addAction(UIAlertAction(title: "Add to Playlist", style: .default, handler: { [weak self] _ in
            guard let strongSelf = self else { return }
            
            DispatchQueue.main.async {
                // open the list of users playlists and select the playlist to add track
                let vc = LibraryPlaylistViewController()
                vc.title = track.name
                // A callback to notify when the playlist is selected
                vc.selectedPlaylist = { playlist in
                    // make a server call to add the track to playlist
                    ApiService.shared.addTrackToPlaylist(playlistId: playlist.id, track: track) { success in
                        DispatchQueue.main.async {
                            if !success {
                                strongSelf.present(strongSelf.showErrorDialog(message: "Could not add track to playlist"), animated: true)
                            }
                        }
                    }
                }
                strongSelf.present(UINavigationController(rootViewController: vc), animated: true)
            }
        }))
        present(actionSheet, animated: true)
    }
    
    private func showError(message: String){
       
    }
    
    private func configureCollectionView(){
        view.addSubview(collectionView)
        view.addSubview(spinner)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(NewReleaseCollectionViewCell.self, forCellWithReuseIdentifier: NewReleaseCollectionViewCell.identifier)
        collectionView.register(FeaturePlaylistCollectionViewCell.self, forCellWithReuseIdentifier: FeaturePlaylistCollectionViewCell.identifier)
        collectionView.register(TrackCollectionViewCell.self, forCellWithReuseIdentifier: TrackCollectionViewCell.identifier)
        collectionView.register(TitleHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TitleHeaderCollectionReusableView.identifier)
        collectionView.backgroundColor = .systemBackground
    }
    
    
    @objc func didTapSettings(){
        let vc = SettingsViewController()
        vc.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func fetchData() {
        spinner.startAnimating()
        
        let group = DispatchGroup()
        
        // models
        var newRelease: NewRelease?
        var featurePlaylist: FeaturedPlaylist?
        var recommendation: Recommendation?
        var currentError: Error?
        
        // fetch data for new releases
        group.enter()
        ApiService.shared.getNewReleases { (result) in
            defer {
                group.leave()
            }
            switch result {
            case .success(let model):
                newRelease = model
            case .failure(let error):
                currentError = error
            }
        }
        
        // fetch data for feature playlists
        group.enter()
        ApiService.shared.getAllFeaturedPlaylists { (result) in
            defer {
                group.leave()
            }
            switch result {
            case .success(let model):
                featurePlaylist = model
            case .failure(let error):
                currentError = error
            }
        }
        
        // fetch data for recommended tracks
        group.enter()
        ApiService.shared.getRecommendedGenres { (result) in
            switch result {
            case .success(let model):
                let genres = model.genres;
                var seeds = Set<String>()
                while seeds.count < 5 {
                    if let randomSeed = genres.randomElement() {
                        seeds.insert(randomSeed)
                    }
                }
                
                ApiService.shared.getRecommendations(genres: seeds) { (recommendedResult) in
                    defer {
                        group.leave()
                    }
                    switch recommendedResult {
                    case .success(let model):
                        recommendation = model
                    case .failure(let error):
                        currentError = error
                    }
                }
            case .failure(let error):
                defer {
                    group.leave()
                }
                currentError = error
            }
        }
        
        
        
        group.notify(queue: .main) {
            self.spinner.stopAnimating()
            if let error = currentError {
                self.present(self.showErrorDialog(message: error.localizedDescription), animated: true)
                return
            }
            guard let albums = newRelease?.albums.items,
                  let playlists = featurePlaylist?.playlists.items,
                  let tracks = recommendation?.tracks else {
                return
            }
            
            // configure models
            self.albums = albums
            self.playlists = playlists
            self.audioTracks = tracks
            self.configureModel()
        }
    }
    
    private func configureModel(){
        // configure Models
        let releaseViewModel = self.albums.compactMap { return NewReleaseCellViewModel(name: $0.name, artworkURL: URL(string: $0.images.first?.url ?? ""), noOfTracks: $0.totalTracks, artistName: $0.artists.first?.name ?? "-") }
        
        let playlistViewModel = self.playlists.compactMap { return FeaturedPlaylistCellViewModel(name: $0.name, creatorName: $0.owner.displayName, artworkURL: URL(string: $0.images.first?.url ?? ""))}
        
        let recommended = self.audioTracks.compactMap { return TrackCellViewModel(name: $0.name, artistName: $0.artists.first?.name ?? "-", artworkURL: URL(string: $0.album!.images.first?.url ?? ""))}
        
        sections.append(.newReleases(viewModels: releaseViewModel))
        sections.append(.featurePlaylists(viewModels: playlistViewModel))
        sections.append(.recommendedTracks(viewModels: recommended))
        collectionView.reloadData()
    }
}

// MARK: Composition Layout methods

extension HomeViewController {

    private static func sectionLayout() -> NSCollectionLayoutSection {
        // Item
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 2.0, leading: 2.0, bottom: 2.0, trailing: 2.0)
        
        // Vertical Group in Horizontal Group
        let height: CGFloat = 390.0
        let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(height)), subitem: item, count: 3)
            
        let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(height)), subitem: verticalGroup, count: 1)
        
        // Section
        let layoutSection = NSCollectionLayoutSection(group: horizontalGroup)
        layoutSection.orthogonalScrollingBehavior = .groupPaging
        
        layoutSection.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50.0)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        ]
        
        return layoutSection
    }
    
    private static func sectionLayout1() -> NSCollectionLayoutSection {
        // Item
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 2.0, leading: 2.0, bottom: 2.0, trailing: 2.0)
        
        // Vertical Group in Horizontal Group
        let height: CGFloat = 372.0
        let width: CGFloat = 186.0
        
        let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(width), heightDimension: .absolute(height)), subitem: item, count: 2)
        
        let horizontalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(width), heightDimension: .absolute(height)), subitem: verticalGroup, count: 1)
        
        
        // Section
        let layoutSection = NSCollectionLayoutSection(group: horizontalGroup)
        layoutSection.orthogonalScrollingBehavior = .continuous
        
        layoutSection.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50.0)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        ]
        
        return layoutSection
    }
    
    private static func sectionLayout2() -> NSCollectionLayoutSection {
        // Item
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 2.0, leading: 2.0, bottom: 2.0, trailing: 2.0)
        
        // Vertical Group in Horizontal Group
        let height: CGFloat = 80.0
      
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(height)), subitem: item, count: 1)
        
        // Section
        let layoutSection = NSCollectionLayoutSection(group: group)
        
        layoutSection.boundarySupplementaryItems = [
            NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50.0)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        ]
        
        return layoutSection
    }
    
    

    private static func createSectionLayout(section: Int) -> NSCollectionLayoutSection {
        switch section {
        case 0:
            return sectionLayout()
        case 1:
            return sectionLayout1()
        case 2:
            return sectionLayout2()
        default:
            return sectionLayout2()
        }
    }

}

// MARK: UICollection methods

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TitleHeaderCollectionReusableView.identifier, for: indexPath) as? TitleHeaderCollectionReusableView, kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let title = sections[indexPath.section].title
        header.configure(with: title)
        return header
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type = sections[section]
        switch type {
        case .newReleases(let viewModels):
            return viewModels.count
        case .featurePlaylists(let viewModels):
            return viewModels.count
        case .recommendedTracks(let viewModels):
            return viewModels.count
        }
    }
        
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let type = sections[indexPath.section]
        switch type {
        case .newReleases(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NewReleaseCollectionViewCell.identifier, for: indexPath) as? NewReleaseCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: viewModels[indexPath.row])
            return cell
        case .featurePlaylists(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturePlaylistCollectionViewCell.identifier, for: indexPath) as? FeaturePlaylistCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: viewModels[indexPath.row])
            return cell
        case .recommendedTracks(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackCollectionViewCell.identifier, for: indexPath) as? TrackCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            cell.configure(with: viewModels[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = sections[indexPath.section]
        
        switch section {
        case .newReleases:
            let album = albums[indexPath.row]
            let vc = AlbumViewController(album: album)
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case .featurePlaylists:
            let playlist = playlists[indexPath.row]
            let vc = PlaylistViewController(playlist: playlist)
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case .recommendedTracks:
            let audioTrack = audioTracks[indexPath.row]
            PlayerPresenter.shared.startPlayback(from: self, track: audioTrack)
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }

}

enum BrowseSectionType {
    case newReleases (viewModels: [NewReleaseCellViewModel])
    case featurePlaylists (viewModels: [FeaturedPlaylistCellViewModel])
    case recommendedTracks (viewModels: [TrackCellViewModel])
    
    var title: String {
        switch self {
        case .newReleases:
            return "New Released Albums"
        case .featurePlaylists:
            return "Featured Playlists"
        case .recommendedTracks:
              return "Recommended"
        }
    }
}

