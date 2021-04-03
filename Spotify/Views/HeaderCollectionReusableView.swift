//
//  PlaylistHeaderCollectionReusableView.swift
//  Spotify
//
//  Created by user on 01/04/2021.
//

import UIKit
import SDWebImage

protocol HeaderCollectionReusableViewDelegate: AnyObject {
    func PlaylistHeaderCollectionReusableViewDidTapPlayAll(_ header: HeaderCollectionReusableView)
}

final class HeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "HeaderCollectionReusableView"
    
    weak var delegate: HeaderCollectionReusableViewDelegate?
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.numberOfLines = 2
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let ownerNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .light)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(systemName: "photo")
        return imageView
    }()
    
    private let playButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 30.0
        let image = UIImage(systemName: "play.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30.0, weight: .regular))
        button.setImage(image, for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        clipsToBounds = true
        addSubview(nameLabel)
        addSubview(descriptionLabel)
        addSubview(ownerNameLabel)
        addSubview(imageView)
        addSubview(playButton)
        playButton.addTarget(self, action: #selector(didTapPlayAll), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize = height / 1.8
        imageView.frame = CGRect(x: (width - imageSize)/2, y: 20, width: imageSize, height: imageSize)
        
        nameLabel.sizeToFit()
        ownerNameLabel.sizeToFit()
        
        nameLabel.frame = CGRect(x: 10, y: imageView.bottom + 8, width: width - 20, height: nameLabel.height)
        descriptionLabel.frame = CGRect(x: nameLabel.left, y: nameLabel.bottom + 8, width: nameLabel.width, height: 45)
        ownerNameLabel.frame = CGRect(x: nameLabel.left, y: descriptionLabel.bottom + 8, width: nameLabel.width, height: ownerNameLabel.height)
        
        playButton.frame = CGRect(x: width - 80, y: ownerNameLabel.top - 5, width: 60.0, height: 60.0)
    }
    
    @objc func didTapPlayAll(){
        delegate?.PlaylistHeaderCollectionReusableViewDidTapPlayAll(self)
    }
    
    func configure (viewModel: HeaderViewViewModel){
        nameLabel.text = viewModel.name
        descriptionLabel.text = viewModel.description
        ownerNameLabel.text = viewModel.ownerName
        imageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
    }
}
