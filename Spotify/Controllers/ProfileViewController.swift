//
//  ProfileViewController.swift
//  Spotify
//
//  Created by user on 23/03/2021.
//

import UIKit
import SDWebImage

class ProfileViewController: UIViewController, Dialog {
    
    // MARK: IBOutlet
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.isHidden = true
        return tableView
    }()
    
    // MARK: Properties
    
    var models: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        fetchProfile()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func fetchProfile(){
        ApiService.shared.getCurrentUserProfile { [weak self] (result) in
            DispatchQueue.main.async {
                switch result{
                case .success(let user):
                    self?.updateUI(with: user)
                    break
                case .failure(_):
                    self?.showErrorMessage()
                    break
                }
            }
        }
    }
    
    private func configureUI(){
        title = "Profile"
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func updateUI(with model: UserProfile) {
        configureModel(with: model)
        tableView.isHidden = false
        tableView.reloadData()
    }
    
    private func configureModel(with user: UserProfile){
        self.createHeaderForImage(with:user.images.first?.url)
        models.append("Full Name: \(user.displayName)")
        models.append("Email Address: \(user.email)")
        models.append("Plan: \(user.product)")
    }
    
    private func createHeaderForImage(with urlString: String?){
        guard let urlString = urlString, let url = URL(string: urlString) else { return }
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: view.width / 1.5))
        let imageSize: CGFloat = headerView.height / 2
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: imageSize, height: imageSize))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageSize/2
        headerView.addSubview(imageView)
        imageView.center = headerView.center
        
        imageView.sd_setImage(with: url, completed: nil)
        tableView.tableHeaderView = headerView
    }
    
    private func showErrorMessage(){
        let label = UILabel(frame: .zero)
        label.text = "Failed to load profile"
        label.sizeToFit()
        label.textColor = .secondaryLabel
        view.addSubview(label)
        label.center = view.center
    }
}

// MARK: TableView

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.text = models[indexPath.row]
        return cell
    }
}
