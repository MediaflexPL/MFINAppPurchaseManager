//
//  MFInAppPurchaseManager.m
//  Trening w domu
//
//  Created by Jakub Darowski on 21.10.2015.
//  Copyright © 2015 Mediaflex Sp. z o. o. All rights reserved.
//

#import "MFInAppPurchaseManager.h"

@implementation MFInAppPurchaseManager

- (instancetype)init
{
    self = [self initWithProductIDs:@[]];
    return self;
}

- (instancetype _Nonnull) initWithProductIDs: (nonnull NSArray*) productIDs {
    self = [super init];
    if (self) {
        _productIDs = productIDs;
        _purchasedProducts = [NSMutableArray array];
        _availableProducts = [NSMutableDictionary dictionaryWithCapacity:[productIDs count]];
        _products = [NSArray array];
        _errors = [NSMutableArray array];
        _requests = [NSMutableArray array];
        _productRequestWasMade = NO;
        _transactionInProgress = NO;
        _hasBoughtPremium = NO;
        _productsHaveBeenRestored = NO;
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

#pragma mark - SKProductsRequestDelegate
-(void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Request did fail with error: %@", error.userInfo);
}

-(void)requestDidFinish:(SKRequest *)request {
    NSLog(@"Request did finish: %@", request);
}

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSLog(@"Product request success");
    if (response.products.count > 0) {
        NSLog(@"Product request success");
        for (SKProduct* product in response.products) {
            _availableProducts[product.productIdentifier] = product;
        }
        _products = [_availableProducts allValues];
        _productRequestWasMade = YES;
    } else {
        [_errors addObject:@{
                            @"date" : [NSDate date],
                            @"message" : @"There are no products available",
                            @"developer_message" : [NSString stringWithFormat:@"response.products.count = %lu", response.products.count]}];
    }
    
    if (response.invalidProductIdentifiers.count > 0) {
        for (NSString* productID in response.invalidProductIdentifiers) {
            [_errors addObject:@{
                                @"date" : [NSDate date],
                                @"message" : @"The given product is currently unavailable.",
                                @"developer_message" : [NSString stringWithFormat:@"The given productID is invalid: %@", productID]
                                }];
        }
    }
    
    NSLog(@"errors: %@", _errors);

}

#pragma mark - SKPaymentTransactionObserver

-(void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray<SKPaymentTransaction *> *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:
                NSLog(@"Transaction completed successfully");
                [queue finishTransaction:transaction];
                _transactionInProgress = NO;
                
                [_purchasedProducts addObject:transaction.payment.productIdentifier];
                // @todo remove this
                // The following line will be removed in the future
                [self didBuyPremium];
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"Transaction failed");
                [_errors addObject:@{
                                     @"date" : [NSDate date],
                                     @"message" : @"A product was not successfully purchased.",
                                     @"developer_message" : [NSString stringWithFormat:@"Product with id=\"%@\" could not be purchased", transaction.payment.productIdentifier]
                                     }];
                [queue finishTransaction:transaction];
                _transactionInProgress = NO;
            default:
                NSLog(@"Transaction state: %ld", (long)transaction.transactionState);
                break;
        }
    }
}

-(void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    NSLog(@"%@",queue );
    NSLog(@"Restored Transactions are once again in Queue for purchasing %@",[queue transactions]);
    
    NSLog(@"received restored transactions: %ld", (long)queue.transactions.count);
    
    for (SKPaymentTransaction *transaction in queue.transactions) {
        NSString *productID = transaction.payment.productIdentifier;
        [_purchasedProducts addObject:transaction.payment.productIdentifier];
        
        NSLog (@"product id is %@" , productID);
        
        // ---- BEGIN DEPRECATED CODE ----
        // @todo remove obsolete code
        if ([_productIDs containsObject:productID]) {
            _hasBoughtPremium = YES;
            NSLog(@"Premium has been restored");
        }
        // ----  END  DEPRECATED CODE ----
    }
    
    _productsHaveBeenRestored = YES;
}

#pragma mark - MFInAppPurchaseManagerJavaScriptMethods
#pragma mark const methods

-(NSDictionary<NSString *,SKProduct *> *)availableProducts {
    return _availableProducts;
}

- (NSArray *) products {
    return _products;
}

- (NSMutableArray *) errors {
    return _errors;
}

- (BOOL) productRequestWasMade {
    return _productRequestWasMade;
}

- (BOOL) transactionInProgress {
    return _transactionInProgress;
}

- (BOOL) productsHaveBeenRestored {
    return _productsHaveBeenRestored;
}

-(NSArray<NSString *> *)purchasedProducts {
    return _purchasedProducts;
}

- (BOOL) hasBoughtPremium {
    // check if the product was already bought
    return _hasBoughtPremium;
}

-(SKProduct *)productWithID:(NSString *)identifier {
    return _availableProducts[identifier];
}

-(BOOL)hasPurchasedProductWithID:(NSString *)identifier {
    return [_purchasedProducts containsObject:identifier];
}


#pragma mark StoreKit interaction

- (void) requestProductInfo {
    if ([SKPaymentQueue canMakePayments]) {
        NSSet* productIdentifiers = [NSSet setWithArray:_productIDs];
        SKProductsRequest* productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
        
        productRequest.delegate = self;
        [_requests addObject:productRequest];
        [productRequest start];
    } else {
        NSLog(@"Can't make payments");
    }
}

- (void) buyProduct:(nonnull SKProduct*) product {
    [self purchaseProduct:product];
}

-(void)purchaseProduct:(SKProduct *)product {
    if (!_transactionInProgress) {
        _transactionInProgress = YES;
        
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        
    }
}

-(void)purchaseProductWithID:(NSString *)identifier {
    [self purchaseProduct:[self productWithID:identifier]];
}

- (void) restorePurchases {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void) didBuyPremium {
    // do whatever you want
    _hasBoughtPremium = YES;
}


@end
