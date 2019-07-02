//
//  EInterPayService.swift
//  EInterPayFramework
//
//  Created by Yi on 2019/7/2.
//  Copyright © 2019 Yi. All rights reserved.
//

import UIKit
import StoreKit

open class EInterPayService: NSObject {

    public static let shared = EInterPayService()
    
    open var userDisabledPayCall: (()->())?
    open var noProductCall: (()->())?
    open var payResult: ((SKPaymentTransaction)->())?
    
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    deinit {
        SKPaymentQueue.default().remove(self)
    }
    
    func pay(_ productId: String) {
        if !SKPaymentQueue.canMakePayments() {
            if self.userDisabledPayCall != nil {
                self.userDisabledPayCall!()
            }
        } else {
            let set: Set = [productId]
            let request = SKProductsRequest(productIdentifiers: set)
            request.delegate = self
            request.start()
        }
    }
}

extension EInterPayService: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let products = response.products
        if products.count == 0 {
            if self.noProductCall != nil {
                self.noProductCall!()
            }
            return
        }
        if let aProduct = products.first {
            let payment = SKPayment(product: aProduct)
            SKPaymentQueue.default().add(payment)
        }
    }
}

extension EInterPayService: SKPaymentTransactionObserver {
    
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            if self.payResult != nil {
                self.payResult!(transaction)
            }
            switch transaction.transactionState {
            case .purchased: // 购买成功
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .purchasing: //
                break
            case .failed: // 交易失败
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .deferred: // 稍等，正在处理
                break
            case .restored: // 已经购买过
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            default:
                break
            }
        }
    }
    
}
