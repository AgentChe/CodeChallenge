//
//  PaygateProductButton.swift
//  CodeChallenge
//
//  Created by Андрей Чернышев on 19.03.2024.
//

import UIKit
import RxCocoa

final class PaygateProductButton: UIButton {
    var marked: Bool = false {
        didSet {
            update()
        }
    }
    
    var product: ProductPrice? {
        didSet {
            update()
        }
    }
    
    lazy var leftLabel = makeLabel()
    lazy var rigthLabel = makeLabel()
    lazy var markerView = makeMarkerView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension PaygateProductButton {
    func update() {
        updateLeft()
        updateRight()
        updateMarker()
    }
    
    func updateLeft() {
        guard let product else {
            return
        }
        
        let isLifetime = isLifetime()
        
        let result = NSMutableAttributedString()
        
        switch isLifetime {
        case true:
            let nameAttrs = TextAttributes()
                .textColor(UIColor.white)
                .font(UIFont.medium(size: 16.scale))
                .lineHeight(22.4.scale)
            let name = "Paygate.Lifetime".localized + "\n"
            result.append(name.attributed(with: nameAttrs))
            
            let priceAttrs = TextAttributes()
                .textColor(UIColor.white)
                .font(UIFont.medium(size: 24.scale))
                .lineHeight(28.8.scale)
            let price = Currency(productPrice: product).formatted()
            result.append((price ?? "").attributed(with: priceAttrs))
            
            let periodAttrs = TextAttributes()
                .textColor(UIColor.white)
                .font(UIFont.medium(size: 14.scale))
                .lineHeight(16.8.scale)
            result.append((" " + "Paygate.PerYear".localized).attributed(with: periodAttrs))
        case false:
            let attrs = TextAttributes()
                .textColor(UIColor.white)
                .font(UIFont.bold(size: 16.scale))
                .lineHeight(22.4.scale)
            result.append("Paygate.QuickPeek".localized.attributed(with: attrs))
        }
        
        leftLabel.attributedText = result
    }
    
    func updateRight() {
        guard let product else {
            return
        }
        
        let isLifetime = isLifetime()
        
        let result = NSMutableAttributedString()
        
        switch isLifetime {
        case true:
            let attrs = TextAttributes()
                .textColor(UIColor.white)
                .font(UIFont.medium(size: 14.scale))
                .lineHeight(19.6.scale)
            result.append(("Paygate.Just".localized + " ").attributed(with: attrs))
            
            let price = Currency(productPrice: product, div: 52).formatted()
            result.append((price ?? "").attributed(with: attrs))
            
            result.append(("\n" + "Paygate.PerWeek".localized).attributed(with: attrs))
        case false:
            let priceAttrs = TextAttributes()
                .textColor(UIColor.white)
                .font(UIFont.medium(size: 22.scale))
                .lineHeight(26.4.scale)
            let price = Currency(productPrice: product).formatted()
            result.append((price ?? "").attributed(with: priceAttrs))
            
            let periodPrice = TextAttributes()
                .textColor(UIColor.white)
                .font(UIFont.medium(size: 14.scale))
                .lineHeight(19.6.scale)
            result.append(("\n" + "Paygate.PerWeek".localized).attributed(with: periodPrice))
        }
        
        rigthLabel.attributedText = result
    }
    
    func isLifetime() -> Bool {
       product?.id == GlobalDefinitions.Paygate.lifetime
    }
    
    func updateMarker() {
        markerView.isHidden = !marked
    }
}

// MARK: Make constraints
private extension PaygateProductButton {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            leftLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            leftLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            rigthLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -54.scale),
            rigthLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            markerView.widthAnchor.constraint(equalToConstant: 24.scale),
            markerView.heightAnchor.constraint(equalToConstant: 24.scale),
            markerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.scale),
            markerView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension PaygateProductButton {
    func makeLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 2
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makeMarkerView() -> UIImageView {
        let view = UIImageView()
        view.clipsToBounds = true
        view.image = UIImage(named: "Paygate.Marker")
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}

// MARK: Additional
private struct Currency {
    enum LTRCurrency: String, CaseIterable {
        case USD = "USD"
    }
    
    private let productPrice: ProductPrice
    private let div: Double
    
    init(productPrice: ProductPrice, div: Double = 1) {
        self.productPrice = productPrice
        self.div = div
    }
    
    func formatted() -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = productPrice.priceLocale
        formatter.maximumFractionDigits = 2
        formatter.roundingMode = .down
        formatter.currencyCode = productPrice.currency
        
        let currencySymbol = formatter.currencySymbol ?? productPrice.currency
        
        formatter.currencyCode = ""
        formatter.currencySymbol = ""
        
        guard let resultPrice = formatter.string(from: NSNumber(value: productPrice.priceValue / div)) else {
            return nil
        }
        
        let ltrCurrencies = LTRCurrency.allCases.map { $0.rawValue }
        
        if ltrCurrencies.contains(productPrice.currency) {
            return String(format: "%@%@", currencySymbol, resultPrice)
        } else {
            return String(format: "%@%@", resultPrice, currencySymbol)
        }
    }
}
