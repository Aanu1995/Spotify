//
//  SearchResultDefaultTableViewCell.swift
//  Spotify
//
//  Created by user on 04/04/2021.
//

import UIKit

class SearchResultDefaultTableViewCell: UITableViewCell {
    static let identifier = "SearchResultDefaultTableViewCell"
    
    private let label: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.tintColor = .label
        return image
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        contentView.addSubview(label)
        contentView.addSubview(iconImageView)
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize = contentView.height - 10
        iconImageView.frame = CGRect(x: 10, y: 5, width: imageSize, height: imageSize)
        iconImageView.layer.cornerRadius = imageSize / 2.0
        iconImageView.layer.masksToBounds = true
        label.frame = CGRect(x: iconImageView.right + 10, y: 0, width: contentView.width - iconImageView.width - 20, height: contentView.height)
       
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        imageView?.image = nil
    }
    
    public func configure(with viewModel: SearchResultDefaultTableViewCellViewModel){
        label.text = viewModel.title
        iconImageView.sd_setImage(with: viewModel.imageURL, placeholderImage: UIImage(systemName: "music.note.list", withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)), completed: nil)
    }

}
