//
//  TitleHeaderCollectionReusableView.swift
//  Spotify
//
//  Created by user on 02/04/2021.
//

import UIKit

class TitleHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "TitleHeaderCollectionReusableView"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22.0, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(titleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = CGRect(x: 15, y: 0, width: width - 30, height: height)
    }
    
    override func prepareForReuse() {
        titleLabel.text = nil
    }
    
    public func configure(with title: String){
        titleLabel.text = title
    }
}
