//
//  PlayerViewController.swift
//  Spotify
//
//  Created by user on 23/03/2021.
//

import UIKit

protocol PlayerViewControllerDatasource: AnyObject {
    var songName: String? { get }
    var subTitle: String? { get }
    var imageURL: URL? { get }
}

protocol PlayerViewControllerDelegate: AnyObject {
    func PlayerViewControllerDelegateDidTapPlayPause()
    func PlayerViewControllerDelegateDidAdjustVolume(to value: Float)
    func PlayerViewControllerDelegateDidTapForward()
    func PlayerViewControllerDelegateDidTapBackward()
}

class PlayerViewController: UIViewController {
    
    // MARK: Properties
    
    weak var dataSource: PlayerViewControllerDatasource?
    weak var delegate: PlayerViewControllerDelegate?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let controlsView: PlayerControlsView = {
        let controlsView = PlayerControlsView()
        return controlsView
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.width)
        controlsView.frame = CGRect(
            x: 10,
            y: imageView.bottom + 10,
            width: view.width - 20,
            height: view.height - view.safeAreaInsets.top - imageView.height - view.safeAreaInsets.bottom - 15
        )
        
        imageView.sd_setImage(with: dataSource?.imageURL, completed: nil)
        let viewModel = PlayViewControlsViewViewModel(title: dataSource?.songName, subTitle: dataSource?.subTitle)
        controlsView.configure(with: viewModel)
    }
    
    // MARK: Methods
    
    private func configureUI(){
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapAction))
        
        view.addSubview(imageView)
        view.addSubview(controlsView)
        print("tapped")
        controlsView.delegate = self
    }
    
   public func refreshUI(){
        configureUI()
    }
    
    @objc private func didTapClose(){
     dismiss(animated: true, completion: nil)
    }
    
    @objc private func didTapAction() {
        
    }
}

// MARK: PlayerControlsViewDelegate

extension PlayerViewController: PlayerControlsViewDelegate {
    
    func PlayerControlsViewDidUpdateSliderVolume(_ controlView: PlayerControlsView, didSelectSlider value: Float) {
        delegate?.PlayerViewControllerDelegateDidAdjustVolume(to: value)
    }
    
    func PlayerControlsViewDidTapPlayPauseButton(_ controlView: PlayerControlsView) {
        delegate?.PlayerViewControllerDelegateDidTapPlayPause()
    }
    
    func PlayerControlsViewDidTapBackwardButton(_ controlView: PlayerControlsView) {
        delegate?.PlayerViewControllerDelegateDidTapBackward()
    }
    
    func PlayerControlsViewDidTapNextutton(_ controlView: PlayerControlsView) {
        delegate?.PlayerViewControllerDelegateDidTapForward()
    }
}
