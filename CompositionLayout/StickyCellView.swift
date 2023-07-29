//
//  StickyCellView.swift
//  CompositionLayout
//
//  Created by Chingiz Zholdaspayev on 29.07.2023.
//

import UIKit

class StickyCellView: UIView {
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("Not implemented")
    }
    
    func configure(
        text: String,
        backgroundColor: UIColor,
        borderWith: CGFloat,
        borderColor: UIColor
    ) {
        self.backgroundColor = backgroundColor
        layer.borderWidth = borderWith
        layer.borderColor = borderColor.cgColor
        layer.masksToBounds = true
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 14)
        addSubview(label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        label.text = text
        label.textAlignment = .center
    }
}
