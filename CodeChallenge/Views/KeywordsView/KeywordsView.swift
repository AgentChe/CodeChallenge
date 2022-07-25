//
//  KeywordsView.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 06/08/2022.
//

import Foundation
import UIKit

class KeywordsView: UIView {
    private let collectionViewLayout: UICollectionViewCompositionalLayout = {
        let layoutSize = NSCollectionLayoutSize(
            widthDimension: .estimated(100),
            heightDimension: .absolute(32)
        )

        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: layoutSize.heightDimension
            ),
            subitems: [.init(layoutSize: layoutSize)]
        )
        group.interItemSpacing = .fixed(8)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
        section.interGroupSpacing = 8

        return .init(section: section)
    }()

    private let collectionView: UICollectionView
    private let collectionViewHeightConstraint: NSLayoutConstraint
    private let keywords: [String]
    var onHeightChange: ((Double) -> Void)?
    var onKeywordTap: ((String) -> Void)?

    init(keywords: [String]) {
        self.keywords = keywords
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        self.collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionViewHeightConstraint = collectionView.heightAnchor.constraint(equalToConstant: 100)
        collectionViewHeightConstraint.isActive = true
        super.init(frame: .zero)
        self.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        collectionView.register(KeywordsCollectionCell.self, forCellWithReuseIdentifier: "default")
        collectionView.dataSource = self
        collectionView.delegate = self
        backgroundColor = .clear
        collectionView.backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.collectionViewHeightConstraint.constant = collectionView.contentSize.height
        onHeightChange?(collectionView.contentSize.height)
    }
}

extension KeywordsView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        keywords.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "default", for: indexPath) as? KeywordsCollectionCell
        cell?.label.text = keywords[indexPath.item]
        return cell!
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onKeywordTap?(keywords[indexPath.item])
    }
}
