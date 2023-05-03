# AkuminaAuthiOSLib

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

AkuminaLib is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'AkuminaAuthiOSLib'
```

## Author
    Akumina

## Usage example

    __import AkuminaAuthiOSLib__
    
    ### Sign-in MSAL with MSAL 
    
     do {
            let clientDetails : ClientDetails =  try ClientDetails(authority: , clientId: , redirectUri: , scopes: , sharePointScope: , appManagerURL: , tenantId: )
                
            try AkuminaLib.instance.authenticateWithMSALAndMAM(parentViewController: self, clientDetails: clientDetails, completionHandler: { result in
                if (result.error != nil) {
                    // Handle MSAL or MAM Error 
                }else {
                    // Check for the token in result. 
                        
                }
            }, loggingHandler: { message, error in
                if(error) {
                    // Handle Error messge
                }else {
                    // Handle Info message 
                }
            })
        }catch{
            // Handle exception here
        }
        
## License

AkuminaAuthiOSLib is available under the MIT license. See the LICENSE file for more info.
