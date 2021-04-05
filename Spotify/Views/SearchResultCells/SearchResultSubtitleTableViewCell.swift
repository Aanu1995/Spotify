//
//  SearchResultDefaultTableViewCell.swift
//  Spotify
//
//  Created by user on 04/04/2021.
//

import UIKit

class SearchResultSubtitleTableViewCell: UITableViewCell {
    static let identifier = "SearchResultSubtitleTableViewCell"
    
    private let label: UILabel = {
        let label = UILabel()
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 14, weight: .regular)
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        return image
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        contentView.addSubview(label)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(iconImageView)
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize = contentView.height - 10
        iconImageView.frame = CGRect(x: 10, y: 5, width: imageSize, height: imageSize-10)
        let labelHeight = contentView.height * 0.5
        label.frame = CGRect(x: iconImageView.right + 10, y: 0, width: contentView.width - iconImageView.width - 20, height: labelHeight)
        subTitleLabel.frame = CGRect(x: iconImageView.right + 10, y: labelHeight, width: contentView.width - iconImageView.width - 20, height: contentView.height - labelHeight)
       
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        imageView?.image = nil
        subTitleLabel.text = nil
    }
    
    public func configure(with viewModel: SearchResultSubtitleTableViewCellViewModel){
        label.text = viewModel.title
        iconImageView.sd_setImage(with: viewModel.imageURL, completed: nil)
        subTitleLabel.text = viewModel.subtitle
    }

}
