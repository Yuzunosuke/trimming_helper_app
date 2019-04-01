//
//  GridCollectionViewCell.swift
//  TrimmingTest
//
//  Created by 堺雄之介 on 2019/03/27.
//  Copyright © 2019 Yunosuke Sakai. All rights reserved.
//

import UIKit

class GridCollectionViewCell: UICollectionViewCell {
    
    let iconImageView = UIImageView()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        contentView.addSubview(iconImageView)
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        iconImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        iconImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 5).isActive = true
        iconImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -5).isActive = true
        iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        iconImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5).isActive = true
    }

}
