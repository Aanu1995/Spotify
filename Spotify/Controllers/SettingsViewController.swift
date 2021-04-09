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

    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureModels()
        configureUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    // MARK: Methods
    
    private func configureUI() {
        title = "Settings"
        view.backgroundColor = .systemBackground
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
    }
    
    private func configureModels() {
        let profileOption = Option(title: "View your profile", handler: { [weak self] in
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
        let actionSheet = UIAlertController(title: "Sign Out", message: "Are you sure?", preferredStyle: .alert)
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        actionSheet.addAction(UIAlertAction(title: "Sign out", style: .destructive, handler: { _ in
           
            AuthManager.shared.signOut { [weak self] success in
                guard let strongSelf = self else { return }
                DispatchQueue.main.async {
                    if success {
                        let navC = UINavigationController(rootViewController: WelcomeViewController())
                        navC.viewControllers.first?.navigationItem.largeTitleDisplayMode = .always
                        navC.navigationBar.prefersLargeTitles = true
                        navC.modalPresentationStyle = .fullScreen
                        strongSelf.present(navC, animated: true, completion: {
                            strongSelf.navigationController?.popToRootViewController(animated: false)
                        })
                    }
                }
            }
        }))
        present(actionSheet, animated: true)
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
        HapticManager.shared.vibrateForSelection()
        let model = sections[indexPath.section].options[indexPath.row]
        model.handler()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
}
