# MFINAppPurchaseManager
A class used to enable In-App Purchases on TVML-based tvOS applications

# Disclaimer
Please note that **this is an early draft**. Its current functionality is limited only to buying only one In-App Purchase, but we _will_ enhance it in the future as needed. Feel free to submit suggestions in the [issues](issues) section.

## Usage
First you must import the file into your `TVApplicationControllerDelegate`:
```objc
#import "MFInAppPurchaseManager.h"
```
After that you need to instantiate the object with your product IDs in your delegate's `appController:evaluateJavaScriptInContext:jsContext` method:
```objc
-(void)appController:(TVApplicationController *)appController evaluateAppJavaScriptInContext:(JSContext *)jsContext {
    MFInAppPurchaseManager *purchaseManager = [[MFInAppPurchaseManager alloc] initWithProductIDs:@[@"my_super_product", @"my_other_super_product"]];
    [purchaseManager requestProductInfo]; // This line is optional, you can do it later on demand
    self.purchaseManager = purchaseManager;
    [jsContext setObject:purchaseManager forKeyedSubscript:@"purchaseManager"];
}
```

Now you have access to your object in your JavaScript file using the global variable `purchaseManager`. Let's try it:
```js
// In the beginning there must be a call to StoreKit to get product definitions. If you did it in Obj-C you don't need to do it again
purchaseManager.requestProductInfo();

// It takes some time to get product info, we can check if it was already made
if (purchaseManager.productRequestWasMade()) {
    // Let's buy something. First we must know which product to buy. Currently there's only one, so that's not really a problem.
    var product = purchaseManager.products()[0]; // Assign the first product to the variable
	purchaseManager.buyProduct(product); // Tell StoreKit to take it from here
} else {
    // Try again later
}
	
```

Restoring previous purchases is also simple:
```js
// We still need the definitions, so make sure they were downloaded
if (purchaseManager.productRequestWasMade()) {
    purchaseManager.restorePurchases();
} else {
    // Try again later
}
```
