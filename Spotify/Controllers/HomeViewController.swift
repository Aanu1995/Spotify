//
//  ViewController.swift
//  Spotify
//
//  Created by user on 22/03/2021.
//

import UIKit

enum BrowseSectionType {
    case newReleases (viewModels: [NewReleaseCellViewModel])
    case featurePlaylists (viewModels: [FeaturedPlaylistCellViewModel])
    case recommendedTracks (viewModels: [RecommendationCellViewModel])
}

class HomeViewController: UIViewController {
    
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
       
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureCollectionView()
        fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        spinner.center = view.center
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .done, target: self, action: #selector(didTapSettings))
    }
    
    private func configureCollectionView(){
        view.addSubview(collectionView)
        view.addSubview(spinner)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(NewReleaseCollectionViewCell.self, forCellWithReuseIdentifier: NewReleaseCollectionViewCell.identifier)
        collectionView.register(FeaturePlaylistCollectionViewCell.self, forCellWithReuseIdentifier: FeaturePlaylistCollectionViewCell.identifier)
        collectionView.register(RecommendedTrackCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
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
                print(error.localizedDescription)
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
                print(error.localizedDescription)
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
                        print(error.localizedDescription)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        
        group.notify(queue: .main) {
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
        
        spinner.stopAnimating()
    }
    
    private func configureModel(){
        // configure Models
        let releaseViewModel = self.albums.compactMap { return NewReleaseCellViewModel(name: $0.name, artworkURL: URL(string: $0.images.first?.url ?? ""), noOfTracks: $0.totalTracks, artistName: $0.artists.first?.name ?? "-") }
        
        let playlistViewModel = self.playlists.compactMap { return FeaturedPlaylistCellViewModel(name: $0.name, creatorName: $0.owner.displayName, artworkURL: URL(string: $0.images.first?.url ?? ""))}
        
        let recommended = self.audioTracks.compactMap { return RecommendationCellViewModel(name: $0.name, artistName: $0.artists.first?.name ?? "-", artworkURL: URL(string: $0.album!.images.first?.url ?? ""))}
        
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

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier, for: indexPath) as? RecommendedTrackCollectionViewCell else {
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
            let vc = AudioTrackViewController(audioTrack: audioTrack)
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        }
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    
    
}

