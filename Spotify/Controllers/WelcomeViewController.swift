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
        button.setTitleColor(.blue, for: .normal)
        
        return button
    }()

    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Spotify"
        view.backgroundColor = .systemGreen
        view.addSubview(signInButton)
        signInButton.addTarget(self, action: #selector(signIn(_:)), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let y = view.height - 45 - 8 - view.safeAreaInsets.bottom
        signInButton.frame = CGRect(x: 20, y: y, width: view.width - 40, height: 45)
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
