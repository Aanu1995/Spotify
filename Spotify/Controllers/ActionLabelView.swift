//
//  ActionLabelView.swift
//  Spotify
//
//  Created by user on 07/04/2021.
//

import UIKit

protocol ActionLabelViewDelegate: AnyObject {
    func actionLabelViewDidTapActionButton()
}

struct ActionLabelViewViewModel {
    let labelTitle: String
    let actionTitle: String
    let actionColor: UIColor
}

class ActionLabelView: UIView {
    
    weak var delegate: ActionLabelViewDelegate?
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitleColor(.link, for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        clipsToBounds = true
        addSubview(label)
        addSubview(button)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        button.frame = CGRect(x: 0, y: height - 30, width: width, height: 30)
        label.frame = CGRect(x: 0, y: 0, width: width, height: height - 30)
    }
    
   @objc private func didTapButton(){
     delegate?.actionLabelViewDidTapActionButton()
   }
    
    public func configure(with viewModel: ActionLabelViewViewModel){
        label.text = viewModel.labelTitle
        button.setTitle(viewModel.actionTitle, for: .normal)
        button.setTitleColor(viewModel.actionColor, for: .normal)
    }
}
