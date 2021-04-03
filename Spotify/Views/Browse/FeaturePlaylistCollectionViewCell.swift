//
//  FeaturePlaylistCollectionViewCell.swift
//  Spotify
//
//  Created by user on 29/03/2021.
//

import UIKit

class FeaturePlaylistCollectionViewCell: UICollectionViewCell {
    static let identifier = "FeaturePlaylistCollectionViewCell"
    
    private let playlistCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let playlistNameLabel: UILabel =  {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private let creatorNameLabel: UILabel =  {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.addSubview(playlistCoverImageView)
        contentView.addSubview(playlistNameLabel)
        contentView.addSubview(creatorNameLabel)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSize = contentView.height * 0.72
        playlistCoverImageView.frame = CGRect(x: contentView.width * 0.15, y: 3, width: imageSize, height: imageSize * 0.9)
        playlistCoverImageView.layer.masksToBounds = true
        playlistCoverImageView.layer.cornerRadius = 4
        
        playlistNameLabel.sizeToFit()
        creatorNameLabel.sizeToFit()
        
        playlistNameLabel.frame = CGRect(x: playlistCoverImageView.left - 20, y: playlistCoverImageView.bottom + 10 , width: playlistCoverImageView.width + 40, height: playlistNameLabel.height)
        
        
        creatorNameLabel.frame = CGRect(x: playlistCoverImageView.left, y: playlistNameLabel.bottom + 6, width: playlistCoverImageView.width, height: creatorNameLabel.height)
        playlistNameLabel.textAlignment = .center
        creatorNameLabel.textAlignment = .center
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playlistNameLabel.text = nil
        playlistCoverImageView.image = nil
        creatorNameLabel.text = nil
    }
    
    func configure(with viewModel: FeaturedPlaylistCellViewModel){
        playlistNameLabel.text = viewModel.name
        playlistCoverImageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
        creatorNameLabel.text = viewModel.creatorName
    }
}
