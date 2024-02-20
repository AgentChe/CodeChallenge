//
//  PaygateView.swift
//  CodeChallenge
//
//  Created by Андрей Чернышев on 20.02.2024.
//

import UIKit

final class PaygateView: UIView {
    lazy var scrollView = makeScrollView()
    lazy var titleLabel = makeTitleLabel()
    lazy var info1Cell = makeInfoCell(number: 1, color: UIColor.white, height: 52.scale)
    lazy var info2Cell = makeInfoCell(number: 2, color: UIColor(rgb: 31), height: 52.scale)
    lazy var info3Cell = makeInfoCell(number: 3, color: UIColor(rgb: 31), height: 52.scale)
    lazy var info4Cell = makeInfoCell(number: 4, color: UIColor(rgb: 31), height: 18.scale)
    lazy var bannerImageView = makeBannerImageView()
    lazy var starsImageView = makeStarsView()
    lazy var reviewsCountLabel = makeReviewsCountLabel()
    lazy var joinCountLabel = makeJoinCountLabel()
    lazy var subscriptionInfoLabel = makeSubscriptionInfoLabel()
    lazy var restoreButton = makeActionButton(title: "Paygate.RestorePurchase".localized)
    lazy var termsAndPrivacyButton = makeActionButton(title: "Paygate.TermsAndPrivacy".localized)
    lazy var closeButton = makeActionButton(title: "Paygate.SkipForNow".localized)
    lazy var bottomContainer = makeBottomContainer()
    lazy var priceLabel = makePriceLabel()
    lazy var buyButton = makeBuyButton()
    lazy var preloader = makePreloader()
    
    private lazy var priceAttrs = TextAttributes()
        .textColor(UIColor.white)
        .font(UIFont.regular(size: 15.scale))
        .lineHeight(21.scale)
        .textAlignment(.center)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension PaygateView {
    func setup(price: String) {
        let result = String(format: "Paygate.Price".localized, price)
        priceLabel.attributedText = result.attributed(with: priceAttrs)
    }
}

// MARK: Private
private extension PaygateView {
    func initialize() {
        backgroundColor = UIColor.black
    }
}

// MARK: Make constraints
private extension PaygateView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomContainer.topAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            titleLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16.scale),
            titleLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16.scale),
            titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            info1Cell.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            info1Cell.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            info1Cell.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 36.scale)
        ])
        
        NSLayoutConstraint.activate([
            info2Cell.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            info2Cell.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            info2Cell.topAnchor.constraint(equalTo: info1Cell.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            info3Cell.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            info3Cell.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            info3Cell.topAnchor.constraint(equalTo: info2Cell.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            info4Cell.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            info4Cell.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            info4Cell.topAnchor.constraint(equalTo: info3Cell.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            bannerImageView.widthAnchor.constraint(equalToConstant: 213.scale),
            bannerImageView.heightAnchor.constraint(equalToConstant: 22.scale),
            bannerImageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            bannerImageView.topAnchor.constraint(equalTo: info4Cell.bottomAnchor, constant: 32.scale)
        ])
        
        NSLayoutConstraint.activate([
            starsImageView.widthAnchor.constraint(equalToConstant: 69.scale),
            starsImageView.heightAnchor.constraint(equalToConstant: 14.scale),
            starsImageView.trailingAnchor.constraint(equalTo: scrollView.centerXAnchor, constant: -2.scale),
            starsImageView.topAnchor.constraint(equalTo: bannerImageView.bottomAnchor, constant: 19.scale)
        ])
        
        NSLayoutConstraint.activate([
            reviewsCountLabel.leadingAnchor.constraint(equalTo: scrollView.centerXAnchor, constant: 2.scale),
            reviewsCountLabel.centerYAnchor.constraint(equalTo: starsImageView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            joinCountLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16.scale),
            joinCountLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16.scale),
            joinCountLabel.topAnchor.constraint(equalTo: bannerImageView.bottomAnchor, constant: 44.scale)
        ])
        
        NSLayoutConstraint.activate([
            subscriptionInfoLabel.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16.scale),
            subscriptionInfoLabel.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16.scale),
            subscriptionInfoLabel.topAnchor.constraint(equalTo: joinCountLabel.bottomAnchor, constant: 26.scale),
            subscriptionInfoLabel.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -104.scale)
        ])
        
        NSLayoutConstraint.activate([
            restoreButton.trailingAnchor.constraint(equalTo: scrollView.centerXAnchor, constant: -12.scale),
            restoreButton.topAnchor.constraint(equalTo: subscriptionInfoLabel.bottomAnchor, constant: 24.scale)
        ])
        
        NSLayoutConstraint.activate([
            termsAndPrivacyButton.leadingAnchor.constraint(equalTo: scrollView.centerXAnchor, constant: 12.scale),
            termsAndPrivacyButton.topAnchor.constraint(equalTo: subscriptionInfoLabel.bottomAnchor, constant: 24.scale)
        ])
        
        NSLayoutConstraint.activate([
            closeButton.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            closeButton.topAnchor.constraint(equalTo: restoreButton.bottomAnchor, constant: 12.scale)
        ])
        
        NSLayoutConstraint.activate([
            bottomContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomContainer.heightAnchor.constraint(equalToConstant: 160.scale)
        ])
        
        NSLayoutConstraint.activate([
            priceLabel.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: 16.scale),
            priceLabel.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -16.scale),
            priceLabel.topAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: 24.scale)
        ])
        
        NSLayoutConstraint.activate([
            buyButton.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: 16.scale),
            buyButton.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -16.scale),
            buyButton.heightAnchor.constraint(equalToConstant: 56.scale),
            buyButton.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 32.scale)
        ])
        
        NSLayoutConstraint.activate([
            preloader.centerXAnchor.constraint(equalTo: bottomContainer.centerXAnchor),
            preloader.centerYAnchor.constraint(equalTo: bottomContainer.centerYAnchor),
            preloader.widthAnchor.constraint(equalToConstant: 45.scale),
            preloader.heightAnchor.constraint(equalToConstant: 45.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension PaygateView {
    func makeScrollView() -> UIScrollView {
        let view = UIScrollView()
        view.backgroundColor = UIColor.clear
        view.showsVerticalScrollIndicator = false
        view.contentInset = UIEdgeInsets()
        view.setContentOffset(CGPoint.zero, animated: false)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeTitleLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(UIColor.white)
            .font(UIFont.medium(size: 22.scale))
            .lineHeight(31.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "Paygate.Title".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }
    
    func makeInfoCell(
        number: Int,
        color: UIColor,
        height: CGFloat
    ) -> PaygateInfoCell {
        let item = PaygateInfoCell.Item(
            iconName: "Paygate.Info\(number)",
            title: "Paygate.Info\(number).Title".localized,
            text: "Paygate.Info\(number).Text".localized,
            color: color,
            height: height
        )
        
        let view = PaygateInfoCell(item: item)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }
    
    func makeBannerImageView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.image = UIImage(named: "Paygate.Logo")
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }
    
    func makeStarsView() -> UIImageView {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.image = UIImage(named: "Paygate.Stars")
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }
    
    func makeReviewsCountLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(UIColor.white)
            .font(UIFont.medium(size: 15.scale))
            .lineHeight(21.scale)
            .textAlignment(.left)
        
        let view = UILabel()
        view.attributedText = "Paygate.ReviewsCount".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }
    
    func makeJoinCountLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(UIColor.white.withAlphaComponent(0.6))
            .font(UIFont.regular(size: 13.scale))
            .lineHeight(18.2.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.attributedText = "Paygate.JoinCount".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }
    
    func makeSubscriptionInfoLabel() -> UILabel {
        let attrs = TextAttributes()
            .textColor(UIColor.white.withAlphaComponent(0.6))
            .font(UIFont.regular(size: 13.scale))
            .lineHeight(18.2.scale)
            .textAlignment(.center)
        
        let view = UILabel()
        view.numberOfLines = 0
        view.attributedText = "Paygate.SubscriptionInfo".localized.attributed(with: attrs)
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }
    
    func makeActionButton(title: String) -> TapAreaButton {
        let attrs = TextAttributes()
            .textColor(UIColor.white.withAlphaComponent(0.6))
            .font(UIFont.medium(size: 13.scale))
        
        let view = TapAreaButton()
        view.setAttributedTitle(title.attributed(with: attrs), for: .normal)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(view)
        return view
    }
    
    func makeBottomContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(rgb: 31)
        view.layer.cornerRadius = 16.scale
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePriceLabel() -> UILabel {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        bottomContainer.addSubview(view)
        return view
    }
    
    func makeBuyButton() -> UIButton {
        let attrs = TextAttributes()
            .textColor(UIColor.white)
            .font(UIFont.medium(size: 15.scale))
        
        let view = UIButton()
        view.setAttributedTitle("Paygate.BuyButton".localized.attributed(with: attrs), for: .normal)
        view.backgroundColor = UIColor(integralRed: 51, green: 117, blue: 246)
        view.layer.cornerRadius = 25.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        bottomContainer.addSubview(view)
        return view
    }
    
    func makePreloader() -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView()
        view.style = .large
        view.color = UIColor.white
        view.hidesWhenStopped = true
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
