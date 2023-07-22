//
//  IAPManager.swift
//  CodeChallenge
//
//  Created by Tatevik Tovmasyan on 23/08/2022.
//

import UIKit
import StoreKit

public typealias SuccessBlock = (String) -> Void
public typealias FailureBlock = (Error?) -> Void
typealias AppStorePayment = SKProduct

class IAPManager : NSObject {

    private var sharedSecret = "238613b2da4f47178ac9bfd52bc85697"
    @objc static let shared = IAPManager()
    @objc private(set) var products : Array<SKProduct>?

    private override init(){}
    private var productIds : Set<String> = []

    private var successBlock : SuccessBlock?
    private var failureBlock : FailureBlock?

    private var refreshSubscriptionSuccessBlock : (() -> Void)?
    private var refreshSubscriptionFailureBlock : FailureBlock?

    @Published var isLoading: Bool = false

    var onLoadPayments: (([AppStorePayment]) -> Void)?

    // MARK:- Main methods
    
    @objc func startWith(arrayOfIds : Set<String>!){
        SKPaymentQueue.default().add(self)
        self.productIds = arrayOfIds
        loadProducts()
    }
    
    func presentCodeRedemptionSheet(success: @escaping SuccessBlock, failure: @escaping FailureBlock) {
        guard SKPaymentQueue.canMakePayments() else {
            return
        }
        guard SKPaymentQueue.default().transactions.last?.transactionState != .purchasing else {
            return
        }
        self.successBlock = success
        self.failureBlock = failure
        SKPaymentQueue.default().presentCodeRedemptionSheet()
    }

    func purchaseProduct(product : SKProduct, success: @escaping SuccessBlock, failure: @escaping FailureBlock){
        guard SKPaymentQueue.canMakePayments() else {
            return
        }
        guard SKPaymentQueue.default().transactions.last?.transactionState != .purchasing else {
            return
        }
        self.successBlock = success
        self.failureBlock = failure
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
    
    func finishLastTransaction() {
        guard let transaction = SKPaymentQueue.default().transactions.last else {
            return
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    func restorePurchases(success: @escaping SuccessBlock, failure: @escaping FailureBlock){
        self.successBlock = success
        self.failureBlock = failure
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func validateReceiptData(success: @escaping () -> Void, failure: @escaping FailureBlock) {
        self.refreshSubscriptionSuccessBlock = success
        self.refreshSubscriptionFailureBlock = failure
        refreshSubscriptionsStatus()
    }

    var receiptData: String? {
        guard let receiptUrl = Bundle.main.appStoreReceiptURL else {
            refreshReceipt()
            return nil
        }
        let receiptData = try? Data(contentsOf: receiptUrl).base64EncodedString()
        return receiptData
    }

    private func refreshSubscriptionsStatus(){
        #if DEBUG
        let urlString = "https://sandbox.itunes.apple.com/verifyReceipt"
        #else
        let urlString = "https://buy.itunes.apple.com/verifyReceipt"
        #endif
        let requestData = ["receipt-data" : receiptData ?? "", "password" : self.sharedSecret, "exclude-old-transactions" : true] as [String : Any]
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        let httpBody = try? JSONSerialization.data(withJSONObject: requestData, options: [])
        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request)  { (data, response, error) in
            DispatchQueue.main.async {
                if data != nil {
                    if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments){
                        self.parseReceipt(json as! Dictionary<String, Any>)
                        return
                    }
                } else {
                    print("error validating receipt: \(error?.localizedDescription ?? "")")
                }
                self.refreshSubscriptionFailureBlock?(error)
                self.cleanUpRefeshReceiptBlocks()
            }
            }.resume()
    }

    /* It's the most simple way to get latest expiration date. Consider this code as for learning purposes. You shouldn't use current code in production apps.
     This code doesn't handle errors or some situations like cancellation date.
     */
    private func parseReceipt(_ json : Dictionary<String, Any>) {
        guard let receipts_array = json["latest_receipt_info"] as? [Dictionary<String, Any>] else {
            self.refreshSubscriptionFailureBlock?(nil)
            self.cleanUpRefeshReceiptBlocks()
            return
        }
        for receipt in receipts_array {
            let productID = receipt["product_id"] as! String
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
            if let date = formatter.date(from: receipt["expires_date"] as! String) {
                if date > Date() {
                    // do not save expired date to user defaults to avoid overwriting with expired date
                    UserDefaults.standard.set(date, forKey: productID)
                }
            }
        }
        self.refreshSubscriptionSuccessBlock?()
        self.cleanUpRefeshReceiptBlocks()
    }

    /*
     Private method. Should not be called directly. Call refreshSubscriptionsStatus instead.
     */
    private func refreshReceipt(){
        let request = SKReceiptRefreshRequest(receiptProperties: nil)
        request.delegate = self
        request.start()
    }

    private func loadProducts(){
        let request = SKProductsRequest.init(productIdentifiers: productIds)
        request.delegate = self
        request.start()
    }

    private func cleanUpRefeshReceiptBlocks(){
        self.refreshSubscriptionSuccessBlock = nil
        self.refreshSubscriptionFailureBlock = nil
    }
}

// MARK:- SKReceipt Refresh Request Delegate
extension IAPManager : SKRequestDelegate {

    func requestDidFinish(_ request: SKRequest) {
//        if request is SKReceiptRefreshRequest {
//            refreshSubscriptionsStatus(callback: self.successBlock ?? {}, failure: self.failureBlock ?? {_ in})
//        }
    }

    func request(_ request: SKRequest, didFailWithError error: Error){
        if request is SKReceiptRefreshRequest {
            self.refreshSubscriptionFailureBlock?(error)
            self.cleanUpRefeshReceiptBlocks()
        }
        print("error: \(error.localizedDescription)")
    }
}

// MARK:- SKProducts Request Delegate
extension IAPManager: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products
        self.onLoadPayments?(response.products)
    }
}

// MARK:- SKPayment Transaction Observer
extension IAPManager: SKPaymentTransactionObserver {

    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {

        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                SKPaymentQueue.default().finishTransaction(transaction)
                notifyIsPurchased(transaction: transaction)
                isLoading = false
                break
            case .failed:
                SKPaymentQueue.default().finishTransaction(transaction)
                print("purchase error : \(transaction.error?.localizedDescription ?? "")")
                self.failureBlock?(transaction.error)
                cleanUp()
                isLoading = false
                break
            case .restored:
                SKPaymentQueue.default().finishTransaction(transaction)
                notifyIsPurchased(transaction: transaction)
                isLoading = false
                break
            case .deferred, .purchasing:
                isLoading = true
                break
            default:
                break
            }
        }
    }

    private func notifyIsPurchased(transaction: SKPaymentTransaction) {
        self.successBlock?(transaction.transactionIdentifier ?? "")
        self.cleanUp()
    }

    func cleanUp(){
        self.successBlock = nil
        self.failureBlock = nil
    }
}
