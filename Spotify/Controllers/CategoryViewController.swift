//
//  CategoryViewController.swift
//  Spotify
//
//  Created by user on 03/04/2021.
//

import UIKit

class CategoryViewController: UIViewController, Dialog {
    private let category: Category!
    
    init(category: Category) {
        self.category = category
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Property
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { (section, _) -> NSCollectionLayoutSection? in
            
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(0.49)), subitem: item, count: 2)
            group.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0)
            
            return NSCollectionLayoutSection(group: group)
        }))
        
        collectionView.backgroundColor = .systemBackground
        return collectionView
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    
    private var playlists: [Playlist] = []
    
    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    // MARK: Methods
    
    private func configureUI(){
        title = category.name
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(FeaturePlaylistCollectionViewCell.self, forCellWithReuseIdentifier: FeaturePlaylistCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemBackground
    }
    
    private func fetchData(){
        spinner.startAnimating()
        ApiService.shared.getCategoryPlaylists(category: category.id, completion: onDetailPlaylistFetched)
    }
    
    private func onDetailPlaylistFetched(result: Result<FeaturedPlaylist, Error>){
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            
            switch result{
            case .success(let model):
                self.playlists = model.playlists.items
                break
            case .failure(let error):
                self.present(self.showErrorDialog(message: error.localizedDescription), animated: true, completion: nil)
                break
            }
            self.collectionView.reloadData()
        }
    }
}


// MARK: CollectionView

extension CategoryViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturePlaylistCollectionViewCell.identifier, for: indexPath) as? FeaturePlaylistCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let playlist = playlists[indexPath.row]
        let viewModel = FeaturedPlaylistCellViewModel(name: playlist.name, creatorName: playlist.owner.displayName, artworkURL: URL(string: playlist.images.first?.url ?? ""))
        cell.configure(with: viewModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let playlist = playlists[indexPath.row]
        let vc = PlaylistViewController(playlist: playlist)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}
