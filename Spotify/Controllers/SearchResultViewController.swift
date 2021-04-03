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
        case .album(model: let models):
            return models.count
        case .artist(let models):
            return models.count
        case .playlist(let models):
            return models.count
        case .track(let models):
            return models.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        switch results[indexPath.section] {
        case .album(model: let models):
            let model = models[indexPath.row]
            cell.textLabel?.text = model.name
        case .artist(let models):
            let model = models[indexPath.row]
            cell.textLabel?.text = model.name
        case .playlist(let models):
            let model = models[indexPath.row]
            cell.textLabel?.text = model.name
        case .track(let models):
            let model = models[indexPath.row]
            cell.textLabel?.text = model.name
        }
      return cell
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
