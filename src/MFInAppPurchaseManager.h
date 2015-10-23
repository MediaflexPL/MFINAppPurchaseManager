//
//  MFInAppPurchaseManager.h
//
//  Created by Jakub Darowski on 21.10.2015.
//  Copyright © 2015 Mediaflex Sp. z o. o. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import <JavaScriptCore/JavaScriptCore.h>


/**
 *  @author Jakub Darowski
 *
 *  This is where the magic happens. Any method declared inside a JSExport protocol 
 *  will be translated into JavaScript. Quite useful.
 */

@protocol MFInAppPurchaseManagerJavaScriptMethods <JSExport>

/**
 *  @author Jakub Darowski
 *
 *  Request data from the App Store
 */
- (void) requestProductInfo;

/**
 *  @author Jakub Darowski
 *
 *  The actual SKProducts returned by StoreKit
 */
- ( NSMutableArray * _Nonnull) products;

/**
 *  @author Jakub Darowski
 *
 *  Some place to accumulate errors whenever they occur, since there
 *  might be little compatibility between Obj-C's and TVJS'
 *  concurrency engines.
 */
- (NSMutableArray * _Nonnull) errors;

/**
 *  @author Jakub Darowski
 *
 *  A guard flag to indicate whether the request was already sent
 *  and it's safe to retrieve products.
 */
- (BOOL) productRequestWasMade;

/**
 *  @author Jakub Darowski
 *
 *  A guard that prevents multiple transactions from starting at the same time.
 */
- (BOOL) transactionInProgress;

/**
 *  @author Jakub Darowski
 *
 *  Tells the manager to begin the purchase process
 *
 *  @param product Product to be bought.
 */
- (void) buyProduct:(nonnull SKProduct*) product;

/**
 *  @author Jakub Darowski
 *
 *  Apple requires you to do a restore button. This is where you might implement it.
 */
- (void) restorePurchases;

/**
 *  @author Jakub Darowski
 *
 *  Checks if premium has been bought
 *
 *  @return Was premium bought or not?
 */
- (BOOL) hasBoughtPremium;

/**
 *  @author Jakub Darowski
 *
 *  Checks if products have been restored.
 *
 *  @return Were they?
 */
- (BOOL) productsHaveBeenRestored;

@end

/**
 *  @author Jakub Darowski
 *
 *  A class for the integration of in-app purchases into a TVML tvOS app. *It must* implement the MFInAppPurchaseManagerJavaScriptMethods protocol defined above.
 */

@interface MFInAppPurchaseManager : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver, MFInAppPurchaseManagerJavaScriptMethods> {
    /**;
     *  @author Jakub Darowski
     *
     *  Product IDs defined in iTunes Connect
     */
    NSArray<NSString*> *_productIDs;
    
    /**
     *  @author Jakub Darowski
     *
     *  SKProducts retrieved from the App Store.
     */
    NSMutableArray<SKProduct*> *_products;
    
    /**
     *  @author Jakub Darowski
     *
     *  Errors accumulated during the lifetime of the purchase manager.
     */
    NSMutableArray<NSDictionary*> *_errors;
    
    /**
     *  @author Jakub Darowski
     *
     *  States if the product request was already made.
     */
    BOOL _productRequestWasMade;
    
    /**
     *  @author Jakub Darowski
     *
     *  States if there is a transaction in progress.
     */
    BOOL _transactionInProgress;
    
    /**
     *  @author Jakub Darowski
     *
     *  States if the user has premium.
     */
    BOOL _hasBoughtPremium;
    
    /**
     *  @author Jakub Darowski
     *
     *  States if a restore has been performed.
     */
    BOOL _productsHaveBeenRestored;
    
    /**
     *  @author Jakub Darowski
     *
     *  A place to ensure the requests are being retain. This proved to be *very* important!
     */
    NSMutableArray<SKProductsRequest*> *_requests;
    
}

/**
 *  @author Jakub Darowski
 *
 *  Initialises the manager with given product IDs.
 *
 *  @param productIDs An array of product IDs.
 *
 *  @return Initalised object.
 */
- (instancetype _Nonnull) initWithProductIDs: (nonnull NSArray*) productIDs;

@end
