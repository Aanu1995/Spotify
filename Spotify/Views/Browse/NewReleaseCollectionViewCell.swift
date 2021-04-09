//
//  NewReleaseCollectionViewCell.swift
//  Spotify
//
//  Created by user on 29/03/2021.
//

import UIKit
import SDWebImage

class NewReleaseCollectionViewCell: UICollectionViewCell {
    static let identifier = "NewReleaseCollectionViewCell"
    
    private let albumCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let albumNameLabel: UILabel =  {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17.5, weight: .semibold)
        label.numberOfLines = 2
        return label
    }()
    
    private let numberOfTracksLabel: UILabel =  {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .thin)
        return label
    }()
    
    private let artistNameLabel: UILabel =  {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .light)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.clipsToBounds = true
        contentView.addSubview(albumCoverImageView)
        contentView.addSubview(albumNameLabel)
        contentView.addSubview(artistNameLabel)
        contentView.addSubview(numberOfTracksLabel)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageSize = contentView.height - 10
        albumCoverImageView.frame = CGRect(x: 5, y: 5, width: imageSize, height: imageSize)
        
        let albumLabelSize = albumNameLabel.sizeThatFits(CGSize(width: contentView.width - imageSize - 20, height: imageSize))
        artistNameLabel.sizeToFit()
        numberOfTracksLabel.sizeToFit()
        
        albumNameLabel.frame = CGRect(x: albumCoverImageView.right + 10, y: 5, width: albumLabelSize.width, height: albumLabelSize.height)
        artistNameLabel.frame = CGRect(x: albumNameLabel.left, y: albumNameLabel.bottom + 10, width: artistNameLabel.width, height: artistNameLabel.height)
        numberOfTracksLabel.frame = CGRect(x: albumNameLabel.left, y: albumCoverImageView.bottom - 25, width: numberOfTracksLabel.width, height: numberOfTracksLabel.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        albumNameLabel.text = nil
        albumCoverImageView.image = nil
        artistNameLabel.text = nil
        numberOfTracksLabel.text = nil
    }
    
    func configure(with viewModel: NewReleaseCellViewModel){
        albumNameLabel.text = viewModel.name
        albumCoverImageView.sd_setImage(with: viewModel.artworkURL, completed: nil)
        artistNameLabel.text = viewModel.artistName
        numberOfTracksLabel.text = "Tracks: \(viewModel.noOfTracks)"
    }
}
