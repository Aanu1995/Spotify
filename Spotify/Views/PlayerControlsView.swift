//
//  PlayerControllerView.swift
//  Spotify
//
//  Created by user on 05/04/2021.
//

import UIKit

protocol PlayerControlsViewDelegate: AnyObject {
    func PlayerControlsViewDidTapPlayPauseButton(_ controlView: PlayerControlsView)
    func PlayerControlsViewDidTapBackwardButton(_ controlView: PlayerControlsView)
    func PlayerControlsViewDidTapNextutton(_ controlView: PlayerControlsView)
    func PlayerControlsViewDidUpdateSliderVolume(_ controlView: PlayerControlsView, didSelectSlider value: Float)
}

struct PlayViewControlsViewViewModel {
    let title: String?
    let subTitle: String?
}


final class PlayerControlsView: UIView {
    
    weak var delegate: PlayerControlsViewDelegate?
    
    private let volumeSlider: UISlider = {
        let slider = UISlider()
        slider.value = 0.5
        slider.thumbTintColor = .black
        return slider
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let backButton: UIButton = {
        let backButton = UIButton()
        backButton.tintColor = .label
        let image = UIImage(systemName: "backward.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        backButton.setImage(image, for: .normal)
        return backButton
    }()
    
    private let playPauseButton: UIButton = {
        let backButton = UIButton()
        backButton.tintColor = .label
        let image = UIImage(systemName: "pause", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        backButton.setImage(image, for: .normal)
        return backButton
    }()
    
    private let nextButton: UIButton = {
        let backButton = UIButton()
        backButton.tintColor = .label
        let image = UIImage(systemName: "forward.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        backButton.setImage(image, for: .normal)
        return backButton
    }()
    
    private var isPlaying = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        clipsToBounds = true
        
        addSubview(titleLabel)
        addSubview(subTitleLabel)
        
        addSubview(volumeSlider)
        
        addSubview(backButton)
        addSubview(nextButton)
        addSubview(playPauseButton)
        
        playPauseButton.addTarget(self, action: #selector(didTapPlayPauseButton), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(didTapBackButton), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(didTapNextButton), for: .touchUpInside)
        volumeSlider.addTarget(self, action: #selector(didUpdateSlider(_:)), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(x: 0, y: 0, width: width, height: 50.0)
        subTitleLabel.frame = CGRect(x: 0, y: titleLabel.bottom + 10, width: width, height: 50.0)
        
        volumeSlider.frame = CGRect(x: 10, y: subTitleLabel.bottom + 20, width: width-20, height: 44)
        
        let buttonSize:CGFloat = 60.0
        playPauseButton.frame = CGRect(x: (width - buttonSize)/2.0, y: volumeSlider.bottom + 20, width: buttonSize, height: buttonSize)
        backButton.frame = CGRect(x: playPauseButton.left - 80.0 - buttonSize, y: playPauseButton.top, width: buttonSize, height: buttonSize)
        nextButton.frame = CGRect(x: playPauseButton.right + 80.0, y: playPauseButton.top, width: buttonSize, height: buttonSize)
    }
    
    @objc private func didTapPlayPauseButton(){
        self.isPlaying = !self.isPlaying
        delegate?.PlayerControlsViewDidTapPlayPauseButton(self)
        
        let pause = UIImage(systemName: "pause", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        let play = UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 34, weight: .regular))
        // update icon
        self.playPauseButton.setImage(self.isPlaying ? pause : play, for: .normal)
    }
    
    @objc private func didTapBackButton(){
        delegate?.PlayerControlsViewDidTapBackwardButton(self)
    }
    
    @objc private func didTapNextButton(){
        delegate?.PlayerControlsViewDidTapNextutton(self)
    }
    
    @objc private func didUpdateSlider(_ slider: UISlider){
        delegate?.PlayerControlsViewDidUpdateSliderVolume(self, didSelectSlider: slider.value)
    }
    
    
    public func configure(with viewModel: PlayViewControlsViewViewModel){
        titleLabel.text = viewModel.title
        subTitleLabel.text = viewModel.subTitle
    }
    
}
