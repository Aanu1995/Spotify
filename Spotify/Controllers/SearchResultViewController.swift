//
//  SearchResultViewController.swift
//  Spotify
//
//  Created by user on 23/03/2021.
//

import UIKit

protocol SearchResultViewControllerDelegate: AnyObject {
    func didTapResult(result: SearchResult, row: Int)
}

class SearchResultViewController: UIViewController {
    
    // MARK: Properties
    weak var delegate: SearchResultViewControllerDelegate?
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.register(SearchResultDefaultTableViewCell.self, forCellReuseIdentifier: SearchResultDefaultTableViewCell.identifier)
        table.register(SearchResultSubtitleTableViewCell.self, forCellReuseIdentifier: SearchResultSubtitleTableViewCell.identifier)
        table.isHidden = true
        return table
    }()
    
    private var results: [SearchResult] = []
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // MARK: Methods
    
    private func configureUI(){
        
        view.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    public func update(with results: [SearchResult]){
        self.results = results
      
        tableView.isHidden = results.isEmpty
        tableView.reloadData()
        
    }
}

extension SearchResultViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch results[section] {
        case .album(let albums):
            return albums.count
        case .artist(let artists):
            return artists.count
        case .playlist(let playlists):
            return playlists.count
        case .track(let audioTracks):
            return audioTracks.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch results[indexPath.section] {
        case .album(model: let albums):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultSubtitleTableViewCell else {
                return UITableViewCell()
            }
            let album = albums[indexPath.row]
            let viewModel = SearchResultSubtitleTableViewCellViewModel(title: album.name, imageURL: URL(string: album.images.first?.url ?? ""), subtitle: album.artists.first?.name ?? "")
            cell.configure(with: viewModel)
            return cell
        case .artist(let artists):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultDefaultTableViewCell.identifier, for: indexPath) as? SearchResultDefaultTableViewCell else {
                return UITableViewCell()
            }
            let model = artists[indexPath.row]
            let viewModel = SearchResultDefaultTableViewCellViewModel(title: model.name, imageURL: URL(string: model.images?.first?.url ?? ""))
            cell.configure(with: viewModel)
            return cell
        case .playlist(let playlists):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultSubtitleTableViewCell else {
                return UITableViewCell()
            }
            let playlist = playlists[indexPath.row]
            let viewModel = SearchResultSubtitleTableViewCellViewModel(title: playlist.name, imageURL: URL(string: playlist.images.first?.url ?? ""), subtitle: playlist.owner.displayName)
            cell.configure(with: viewModel)
            return cell
        case .track(let audiTracks):
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultSubtitleTableViewCell else {
                return UITableViewCell()
            }
            let track = audiTracks[indexPath.row]
            let viewModel = SearchResultSubtitleTableViewCellViewModel(title: track.name, imageURL: URL(string: track.album?.images.first?.url ?? ""), subtitle: track.artists.first?.name ?? "")
            cell.configure(with: viewModel)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return results[section].title
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let result = results[indexPath.section]
        delegate?.didTapResult(result: result, row: indexPath.row)
    }
}
