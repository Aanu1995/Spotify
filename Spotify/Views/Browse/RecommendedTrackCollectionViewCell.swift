//
//  RecommendedTrackCollectionViewCell.swift
//  Spotify
//
//  Created by user on 29/03/2021.
//

import UIKit

class RecommendedTrackCollectionViewCell: UICollectionViewCell {
    static let identifier = "RecommendedTrackCollectionViewCell"
    
    private let albumCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let trackNameLabel: UILabel =  {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        return label
    }()
    
    private let artistNameLabel: UILabel =  {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.clipsToBounds = true
        contentView.addSubview(albumCoverImageView)
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSize = contentView.height - 6
        albumCoverImageView.frame = CGRect(x: 3, y: 3, width: imageSize, height: imageSize)
        
        trackNameLabel.sizeToFit()
        artistNameLabel.sizeToFit()
        
        trackNameLabel.frame = CGRect(x: albumCoverImageView.right + 10, y: 10, width: contentView.width - albumCoverImageView.width - 10, height: trackNameLabel.height)
        
        
        artistNameLabel.frame = CGRect(x: trackNameLabel.left, y: trackNameLabel.bottom + 16, width: trackNameLabel.width, height: artistNameLabel.height)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackNameLabel.text = nil
        albumCoverImageView.image = UIImage(systemName: "photo")
        artistNameLabel.text = nil
    }
    
    func configure(with viewModel: RecommendationCellViewModel){
        trackNameLabel.text = viewModel.name
        albumCoverImageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
        artistNameLabel.text = viewModel.artistName
    }
}
