//
//  AlbumCollectionViewCell.swift
//  Spotify
//
//  Created by user on 02/04/2021.
//

import UIKit

class AlbumTrackCollectionViewCell: UICollectionViewCell {
    static let identifier = "AlbumCollectionViewCell"
    
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
        contentView.addSubview(trackNameLabel)
        contentView.addSubview(artistNameLabel)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        trackNameLabel.sizeToFit()
        artistNameLabel.sizeToFit()
        
        trackNameLabel.frame = CGRect(x: 10, y: 5, width: contentView.width - 20, height: trackNameLabel.height)
        
        
        artistNameLabel.frame = CGRect(x: trackNameLabel.left, y: trackNameLabel.bottom + 16, width: trackNameLabel.width, height: artistNameLabel.height)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        trackNameLabel.text = nil
        artistNameLabel.text = nil
    }
    
    func configure(with viewModel: AlbumTrackCellViewModel){
        trackNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
    }
}
