# MFINAppPurchaseManager
A class used to enable In-App Purchases on TVML-based tvOS applications

# Disclaimer
This class has been improved a little bit, but **it might contain various bugs** as it is a byproduct of creating tvOS apps. It will be released as a Cocoa Pod as soon as it becomes able to run on its own.
Feel free to submit any suggestions or bug reports in the [issues](issues) section.

## Documentation
The documentation is located in this repository in the _docs_ directory.

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
    var product = purchaseManager.productWithID("my_super_product"); // Assign the desired product to the variable
	purchaseManager.purchaseProduct(product); // Tell StoreKit to take it from here
	purchaseManager.purchaseProductWithID("my_super_product"); // Or tell the class do handle its own stuff like retrieving the product
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

## Changelog:
* 1.1:
    + Added support for multiple products
	+ Made the methods more consistent
	+ Deprecated the inconsistent ones

* 1.0:
    + Initial release
