//
//  SettingsViewController.swift
//  Spotify
//
//  Created by user on 23/03/2021.
//

import UIKit


class SettingsViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    var sections: [Section] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureModels()
        configureUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func configureUI() {
        title = "Settings"
        view.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
    }
    
    private func configureModels() {
        let profileOption = Option(title: "View the profile", handler: { [weak self] in
            DispatchQueue.main.async { self?.viewProfile() }
        })
        let signOutOption = Option(title: "Sign Out", handler: { [weak self] in
            DispatchQueue.main.async { self?.signOut() }
        })
        
        sections.append(Section(title: "Profile", options: [profileOption]))
        sections.append(Section(title: "Account", options: [signOutOption]))
    }
    
    private func viewProfile(){
        let vc = ProfileViewController()
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func signOut(){
       
    }
    
}

// MARK: TableView

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let model = sections[indexPath.section].options[indexPath.row]
        cell.textLabel?.text = model.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = sections[indexPath.section].options[indexPath.row]
        model.handler()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}
