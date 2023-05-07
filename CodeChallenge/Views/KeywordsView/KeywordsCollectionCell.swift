//
//  KeywordsCollectionCell.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 06/08/2022.
//

import Foundation
import UIKit

protocol KeywordViewCell {
    var label: UILabel { get set }
}

class KeywordsCollectionCell: UICollectionViewCell, KeywordViewCell {
    var label: UILabel = {
        let label = UILabel()
        label.font = .bodyText
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        layer.cornerRadius = 5

        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        ])
        backgroundColor = .CodeChallenge.gray1
        label.textColor = .white.withAlphaComponent(0.7)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

class LessonQuizWordView: UICollectionViewCell, KeywordViewCell {
    var label: UILabel = {
        let label = UILabel()
        label.font = .bodyText
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        layer.cornerRadius = 8
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1

        contentView.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 14),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -14)
        ])
        backgroundColor = .CodeChallenge.gray1
        label.textColor = .white.withAlphaComponent(0.7)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
