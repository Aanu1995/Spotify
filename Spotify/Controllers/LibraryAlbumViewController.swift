//
//  LibraryAlbumViewController.swift
//  Spotify
//
//  Created by user on 06/04/2021.
//

import UIKit

class LibraryAlbumViewController: UIViewController, Dialog {
    
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
    
    private let noAlbumView: ActionLabelView = {
        let actionView = ActionLabelView()
        actionView.isHidden = true
        return actionView
    }()
    
   
    
    private var albums: [Album] = []
    private var error: Error?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(onNotified), name: .albumSaveNotification, object: nil)

       configureUI()
       fetchUserAlbums()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        spinner.center = view.center
        tableView.frame = view.bounds
        noAlbumView.frame = CGRect(x: 20, y: (view.height - 80) / 2, width: view.width - 40, height: 60)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Methods
    
    private func configureUI(){
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(spinner)
        view.addSubview(noAlbumView)
        tableView.delegate = self
        tableView.dataSource = self
        noAlbumView.delegate = self
    }
    
    private func fetchUserAlbums(){
        spinner.startAnimating()
        noAlbumView.isHidden = true
        error = nil
       ApiService.shared.getCurrentUserAlbums(completion: onDetailPlaylistFetched)
    }
    
    private func onDetailPlaylistFetched(result: Result<LibraryAlbumResponse, Error>) {
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            switch result{
            case .success(let model):
                self.albums = model.items.compactMap({$0.album})
            case .failure(let error):
                self.error = error
                self.present(self.showErrorDialog(message: error.localizedDescription), animated: true)
            }
            self.updateUI()
        }
    }

    private func updateUI() {
        if albums.isEmpty {
            noAlbumView.isHidden = false
            if let _ = error {
                noAlbumView.configure(with: ActionLabelViewViewModel(labelTitle: "It seems we encountered an error", actionTitle: "Try Again", actionColor: .systemRed))
            } else {
                noAlbumView.configure(with: ActionLabelViewViewModel(labelTitle: "You have not saved any albums yet", actionTitle: "Browse", actionColor: .link))
            }
        } else {
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
    
    @objc func onNotified(){
       fetchUserAlbums()
    }
}

// MARK: ActionLabelViewDelegate (Tabs)

extension LibraryAlbumViewController: ActionLabelViewDelegate {
    
    func actionLabelViewDidTapActionButton() {
        if let _ = error {
            fetchUserAlbums()
        } else {
            tabBarController?.selectedIndex = 0
        }
    }
}

// MARK: TableView

extension LibraryAlbumViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier:SearchResultSubtitleTableViewCell.identifier    , for: indexPath) as? SearchResultSubtitleTableViewCell else {
            return SearchResultSubtitleTableViewCell()
        }
        let album = albums[indexPath.row]
        let viewModel = SearchResultSubtitleTableViewCellViewModel(title: album.name, imageURL: URL(string: album.images.first?.url ?? ""), subtitle: album.artists.first?.name ?? "")
        cell.configure(with: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let album = albums[indexPath.row]
        let vc = AlbumViewController(album: album)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

}
