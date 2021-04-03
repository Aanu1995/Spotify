//
//  GenreCollectionViewCell.swift
//  Spotify
//
//  Created by user on 02/04/2021.
//

import UIKit

class GenreCollectionViewCell: UICollectionViewCell {
    static let identifier = "GenreCollectionViewCell"
    
    private let colors: [UIColor] = [
        .systemPink,
        .systemBlue,
        .systemPurple,
        .systemGreen,
        .systemRed,
        .systemOrange,
        .darkGray,
        .systemYellow,
        .systemTeal
    ]
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        imageView.image = UIImage(systemName: "music.quarternote.3", withConfiguration: UIImage.SymbolConfiguration(pointSize: 50.0, weight: .regular))
        return imageView
    }()
    
    private let genreLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        contentView.addSubview(imageView)
        contentView.addSubview(genreLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        genreLabel.frame = CGRect(x: 10, y: contentView.height/2, width: contentView.width - 20, height: contentView.height/2)
        imageView.frame = CGRect(x: contentView.width/2, y: 10, width: contentView.width/2, height: contentView.height/2)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        genreLabel.text = nil
    }
    
    public func configure(with title: String){
        genreLabel.text = title
        contentView.backgroundColor = colors.randomElement()
    }
}
