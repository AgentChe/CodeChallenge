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
        
        let isYearly = isYearly()
        
        let result = NSMutableAttributedString()
        
        switch isYearly {
        case true:
            let nameAttrs = TextAttributes()
                .textColor(UIColor.white)
                .font(UIFont.medium(size: 14.scale))
                .lineHeight(19.6.scale)
            let name = "Paygate.Yearly".localized + "\n"
            result.append(name.attributed(with: nameAttrs))
            
            let bottomAttrs = TextAttributes()
                .textColor(UIColor.white)
                .font(UIFont.medium(size: 16.scale))
                .lineHeight(19.2.scale)
            let price = Currency(productPrice: product).formatted() ?? ""
            let bottom = String(format: "Paygate.Yearly.Bottom".localized, price)
            result.append(bottom.attributed(with: bottomAttrs))
        case false:
            let attrs = TextAttributes()
                .textColor(UIColor.white)
                .font(UIFont.medium(size: 14.scale))
                .lineHeight(19.6.scale)
            result.append("Paygate.FreeTrialDays".localized.attributed(with: attrs))
        }
        
        leftLabel.attributedText = result
    }
    
    func updateRight() {
        guard let product else {
            return
        }
        
        let isYearly = isYearly()
        
        let result = NSMutableAttributedString()
        
        switch isYearly {
        case true:
            let priceAttrs = TextAttributes()
                .textColor(UIColor.white)
                .font(UIFont.medium(size: 16.scale))
                .lineHeight(22.4.scale)
            let price = Currency(productPrice: product, div: 52).formatted() ?? ""
            result.append((price + "\n").attributed(with: priceAttrs))
            
            let periodAttrs = TextAttributes()
                .textColor(UIColor.white)
                .font(UIFont.regular(size: 14.scale))
                .lineHeight(19.6.scale)
            result.append("Paygate.PerWeek".localized.attributed(with: periodAttrs))
        case false:
            let priceAttrs = TextAttributes()
                .textColor(UIColor.white)
                .font(UIFont.medium(size: 16.scale))
                .lineHeight(22.4.scale)
            let price = Currency(productPrice: product).formatted() ?? ""
            result.append(String(format: "Paygate.Then".localized, price).attributed(with: priceAttrs))
            
            let periodAttrs = TextAttributes()
                .textColor(UIColor.white)
                .font(UIFont.regular(size: 14.scale))
                .lineHeight(19.6.scale)
            result.append("Paygate.PerWeek".localized.attributed(with: periodAttrs))
        }
        
        rigthLabel.attributedText = result
    }
    
    func isYearly() -> Bool {
       product?.id == GlobalDefinitions.Paygate.yearly
    }
    
    func updateMarker() {
        let imageName = marked ? "Paygate.Marker.S" : "Paygate.Marker.D"
        markerView.image = UIImage(named: imageName)
        
        backgroundColor = marked ? UIColor(integralRed: 58, green: 107, blue: 243, alpha: 0.3) : UIColor.clear
        layer.borderColor = marked ? UIColor(integralRed: 58, green: 107, blue: 243).cgColor : UIColor(integralRed: 46, green: 46, blue: 53).cgColor
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
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
