//
//  WelcomeViewController.swift
//  Spotify
//
//  Created by user on 23/03/2021.
//

import UIKit

class WelcomeViewController: UIViewController, Dialog {
    
    // MARK: Properties
    
    private let signInButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("Sign In with Spotify", for: .normal)
        button.layer.cornerRadius = 5
        button.setTitleColor(.black, for: .normal)
        
        return button
    }()
    
    private let backgroundImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "album")
        return imageView
    }()
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.7
        return view
    }()
    
    private let logoImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "Logo")
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 32, weight: .semibold)
        label.text = "Listen to millions \nof songs on \nthe go"
        return label
    }()

    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Spotify"
        let titleAttributes: [NSAttributedString.Key : Any] = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = titleAttributes
        view.backgroundColor = .systemBackground
        view.addSubview(backgroundImage)
        view.addSubview(overlayView)
        view.addSubview(logoImage)
        view.addSubview(label)
        view.addSubview(signInButton)
        signInButton.addTarget(self, action: #selector(signIn(_:)), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundImage.frame = view.bounds
        overlayView.frame = view.bounds
        let y = view.height - 45 - 8 - view.safeAreaInsets.bottom
        signInButton.frame = CGRect(x: 20, y: y, width: view.width - 40, height: 45)
        logoImage.frame = CGRect(x: (view.width - 120)/2, y: (view.height - 240)/2, width: 120, height: 120)
        label.frame = CGRect(x: 30, y: logoImage.bottom + 30, width: view.width - 60, height: 120)
    }
   
    // MARK: Methods
    
    @objc func signIn(_ sender: Any) {
        let vc = AuthViewController()
        vc.completionHandler = { [weak self] success in
            DispatchQueue.main.async {
                self?.handleSignIn(success: success)
            }
        }
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func handleSignIn(success: Bool){
        guard success else {
            let message = "Something went wrong when signing in. Please try again"
            // show error dialog
            present(showErrorDialog(title: "Oops", message: message), animated: true)
            return
        }
        
        let vc = TabBarViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
}
