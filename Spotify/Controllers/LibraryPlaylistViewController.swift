//
//  LibraryPlaylistViewController.swift
//  Spotify
//
//  Created by user on 06/04/2021.
//

import UIKit

class LibraryPlaylistViewController: UIViewController, Dialog {
    
    // MARK: Properties
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = .label
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .systemBackground
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(SearchResultSubtitleTableViewCell.self, forCellReuseIdentifier: SearchResultSubtitleTableViewCell.identifier)
        return tableView
    }()
    
    private let noPlaylistsView: ActionLabelView = {
        let actionView = ActionLabelView()
        actionView.isHidden = true
        return actionView
    }()
    
   
    
    private var playlists: [Playlist] = []
    private var error: Error?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

       configureUI()
       fetchUserPlaylists()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        spinner.center = view.center
        tableView.frame = view.bounds
        noPlaylistsView.frame = CGRect(x: 20, y: (view.height - 80) / 2, width: view.width - 40, height: 60)
    }
    
    // MARK: Methods
    
    private func configureUI(){
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(spinner)
        view.addSubview(noPlaylistsView)
        tableView.delegate = self
        tableView.dataSource = self
        noPlaylistsView.delegate = self
        
    }
    
    private func fetchUserPlaylists(){
        spinner.startAnimating()
        noPlaylistsView.isHidden = true
        error = nil
        ApiService.shared.getCurrentUserPlaylists(completion: onDetailPlaylistFetched)
    }
    
    private func onDetailPlaylistFetched(result: Result<PlaylistResponse, Error>) {
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            switch result{
            case .success(let model):
                self.playlists = model.items
            case .failure(let error):
                self.error = error
                self.present(self.showErrorDialog(message: error.localizedDescription), animated: true, completion: nil)
            }
            self.updateUI()
        }
    }
    
    private func updateUI() {
        if playlists.isEmpty {
            noPlaylistsView.isHidden = false
            if let _ = error {
                noPlaylistsView.configure(with: ActionLabelViewViewModel(labelTitle: "It seems we encountered an error", actionTitle: "Try Again", actionColor: .systemRed))
            } else {
                noPlaylistsView.configure(with: ActionLabelViewViewModel(labelTitle: "You don't have any playlists yet", actionTitle: "Create", actionColor: .link))
            }
        } else {
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
    
    public func createPlaylist() {
        let alertVC = UIAlertController(
            title: "New Playlist",
            message: "Enter playlist name",
            preferredStyle: .alert
        )
        alertVC.addTextField { (textField) in
            textField.placeholder = "Playlist..."
        }
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertVC.addAction(UIAlertAction(title: "Create", style: .default, handler: { _ in
            guard let textfield = alertVC.textFields?.first, let text = textfield.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
            ApiService.shared.createPlaylists(with: text, completion: self.isPlaylistAdded)
            
        }))
        present(alertVC, animated: true, completion: nil)
    }
    
    private func isPlaylistAdded(success: Bool) {
        DispatchQueue.main.async {
            if success {
                self.fetchUserPlaylists()
            } else {
               return self.present(self.showErrorDialog(message: "Failed to create playlist"), animated: true, completion: nil)
            }
        }
    }
}

// MARK: ActionLabelViewDelegate (Tabs)

extension LibraryPlaylistViewController: ActionLabelViewDelegate {
    
    func actionLabelViewDidTapActionButton() {
        if let _ = error {
            fetchUserPlaylists()
        } else {
            createPlaylist()
        }
    }
}

// MARK: TableView

extension LibraryPlaylistViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier:SearchResultSubtitleTableViewCell.identifier    , for: indexPath) as? SearchResultSubtitleTableViewCell else {
            return SearchResultSubtitleTableViewCell()
        }
        let playlist = playlists[indexPath.row]
        let viewModel = SearchResultSubtitleTableViewCellViewModel(title: playlist.name, imageURL: URL(string: playlist.images.first?.url ?? ""), subtitle: playlist.owner.displayName)
        cell.configure(with: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let playlist = playlists[indexPath.row]
        let vc = PlaylistViewController(playlist: playlist)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}
