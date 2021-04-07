//
//  SearchViewController.swift
//  Spotify
//
//  Created by user on 22/03/2021.
//

import UIKit
import SafariServices

class SearchViewController: UIViewController, Dialog {
    
    // MARK: Properties
    
    private let searchController: UISearchController = {
        let vc = UISearchController(searchResultsController: SearchResultViewController())
        vc.searchBar.placeholder = "Songs, Artists, Albums"
        vc.searchBar.searchBarStyle = .minimal
        vc.definesPresentationContext = true
        return vc
    }()
    
    private let collectionView: UICollectionView = {
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { (_, _) -> NSCollectionLayoutSection? in
            
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 7, bottom: 0, trailing: 7)
            
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(150.0)), subitem: item, count: 2)
            group.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)
            
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
    
    private var categoryList: [Category] = []
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchCategory()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    // MARK: Methods
    
    private func configureUI(){
        view.backgroundColor = .systemBackground
        navigationItem.searchController = searchController
        searchController.searchBar.delegate = self
        
        view.addSubview(collectionView)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(CategoryCollectionViewCell.self, forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func fetchCategory(){
        spinner.startAnimating()
        ApiService.shared.getCategories(completion: onDetailPlaylistFetched)
    }
    
    private func onDetailPlaylistFetched(result: Result<CategoryResponse, Error>) {
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            
            switch result{
            case .success(let model):
                self.categoryList = model.categories.items
                break
            case .failure(let error):
                self.present(self.showErrorDialog(message: error.localizedDescription), animated: true, completion: nil)
                break
            }
            self.collectionView.reloadData()
        }
    }
    
    private func fetchSearchedData(query: String, viewController: SearchResultViewController) {
        ApiService.shared.search(with: query) { (result) in
            DispatchQueue.main.async {
                switch result{
                case .success(let results):
                    return viewController.update(with: results)
                case .failure:
                    break
                }
            }
        }
    }
}

// MARK: Search

extension SearchViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchResultsViewController = searchController.searchResultsController as? SearchResultViewController, let query = searchBar.text, !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        searchResultsViewController.delegate = self
        fetchSearchedData(query: query, viewController: searchResultsViewController)
    }
}

// MARK: CollectionView

extension SearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as? CategoryCollectionViewCell else {
            return UICollectionViewCell()
        }
        let category = categoryList[indexPath.row]
        let viewModel = CategoryCellViewModel(name: category.name, url: URL(string: category.icons.first?.url ?? ""))
        cell.configure(with: viewModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let category = categoryList[indexPath.row]
        let vc = CategoryViewController(category: category)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

// MARK: SearchResultViewControllerDelegate

extension SearchViewController: SearchResultViewControllerDelegate {

    func didTapResult(result: SearchResult, row: Int) {
        switch result {
        case .album(model: let albums):
            let album = albums[row]
            let vc = AlbumViewController(album: album)
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case .artist(let artists):
            let artist = artists[row]
            guard let url = URL(string: artist.externalURLs["spotify"] ?? "") else { return }
            let vc = SFSafariViewController(url: url)
            present(vc, animated: true, completion: nil)
        case .playlist(let playlists):
            let playlist = playlists[row]
            let vc = PlaylistViewController(playlist: playlist)
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case .track(let audioTracks):
            let audioTrack = audioTracks[row]
            PlayerPresenter.shared.startPlayback(from: self, track: audioTrack)
        }
    }
    
    
}


