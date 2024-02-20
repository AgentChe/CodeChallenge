//
//  PaygateViewModel.swift
//  CodeChallenge
//
//  Created by Андрей Чернышев on 20.02.2024.
//

import RxSwift
import RxCocoa

final class PaygateViewModel {
    enum Route {
        case dismiss
        case error
        case open(URL)
    }
    
    private lazy var activity = RxActivityIndicator()
    
    private lazy var iapManager = IAPManager()
    private lazy var paygateInteractor = PaygateInteractor()
}

// MARK: Public
extension PaygateViewModel {
    struct Input {
        let didTapClose: Signal<Void>
        let didTapBuy: Signal<Void>
        let didTapRestore: Signal<Void>
        let didTapTermsAndPolicy: Signal<Void>
    }
    
    struct Output {
        let activity: Driver<Bool>
        let route: Driver<Route>
        let price: Driver<String>
    }
    
    func configure(input: Input) -> Output {
        Output(
            activity: activity.asDriver(),
            route: makeRoute(
                didTapClose: input.didTapClose,
                didTapBuy: input.didTapBuy,
                didTapRestore: input.didTapRestore,
                didTapTermsAndPolicy: input.didTapTermsAndPolicy
            ),
            price: makePrice()
        )
    }
}

// MARK: Private
private extension PaygateViewModel {
    func makePrice() -> Driver<String> {
        iapManager
            .obtainPrices(for: [GlobalDefinitions.Paygate.weekly])
            .compactMap { prices -> String? in
                guard let price = prices.first(where: { $0.id == GlobalDefinitions.Paygate.weekly }) else {
                    return nil
                }
                
                let result = NSNumber(value: price.priceValue / 7)
                
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                formatter.locale = price.priceLocale
                formatter.currencyCode = price.currency
                formatter.maximumFractionDigits = 2
                formatter.roundingMode = .down
                
                return formatter.string(from: result)
            }
            .trackActivity(activity)
            .asDriver(onErrorJustReturn: "")
    }
    
    func makeRoute(
        didTapClose: Signal<Void>,
        didTapBuy: Signal<Void>,
        didTapRestore: Signal<Void>,
        didTapTermsAndPolicy: Signal<Void>
    ) -> Driver<Route> {
        let dismiss = didTapClose
            .map { Route.dismiss }
            .asDriver(onErrorDriveWith: .never())
        let buy = makeBuyed(didTapBuy: didTapBuy)
            .map { $0 ? Route.dismiss : Route.error }
        let restore = makeRestored(didTapRestore: didTapRestore)
            .map { $0 ? Route.dismiss : Route.error }
        let termsAndPolicy = didTapTermsAndPolicy
            .map { Route.open(GlobalDefinitions.termsOfUse) }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(dismiss, buy, restore, termsAndPolicy)
    }
    
    func makeBuyed(didTapBuy: Signal<Void>) -> Driver<Bool> {
        didTapBuy
            .flatMapLatest { [weak self] void -> Driver<Bool> in
                guard let self = self else {
                    return .never()
                }
                
                return self.paygateInteractor
                    .makeActiveSubscription(by: .buy(GlobalDefinitions.Paygate.weekly))
                    .map { result -> Bool in
                        switch result {
                        case .completed(let response):
                            return response
                        case .cancelled:
                            return false
                        }
                    }
                    .trackActivity(self.activity)
                    .asDriver(onErrorJustReturn: false)
            }
    }
    
    func makeRestored(didTapRestore: Signal<Void>) -> Driver<Bool> {
        didTapRestore
            .flatMapLatest { [weak self] _ -> Driver<Bool> in
                guard let self = self else {
                    return .never()
                }
                
                return self.paygateInteractor
                    .makeActiveSubscription(by: .restore)
                    .map { result -> Bool in
                        switch result {
                        case .completed(let response):
                            return response
                        case .cancelled:
                            return false
                        }
                    }
                    .trackActivity(self.activity)
                    .asDriver(onErrorJustReturn: false)
            }
    }
}
