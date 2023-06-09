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

   import AkuminaAuthiOSLib
    
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
   ### Sign-in MSAL only
           
       do {
            let clientDetails : ClientDetails =  try ClientDetails(authority: , clientId: , redirectUri: , scopes: , sharePointScope: , appManagerURL: , tenantId: )
                
            try AkuminaLib.instance.authenticateWithMSAL(parentViewController: self, clientDetails: clientDetails, completionHandler: { result in
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
   ### After sign-in to get token 
        
        do {
            try let token = AkuminaLib.instance.getToken(type: TokenType);
            // TokenType are 
                TokenType.ACCESS --  To get Akumina Token 
                TokenType.GRAPH --  To get Graph token 
                TokenType.SHAREPOINT -- To get sharepoint token 
        }catch{
            // Handle exception here. 
        }
   ### To call Akumina REST API 
   #### To call REST API with out Payload 
          do {
                Akumina.instance.callAkuminaAPI(endPoint: String, method: String,accessToken: String?, query:
                               Dictionary<String,String>, payLoad: Data? , completionHandler: @escaping (_ success: Bool, _ data: Data? , _ error: Error?) -> Void )
          }catch{
                // Handle exception 
          }
   
   #### To call REST API with Payload 
    
     do {
                Akumina.instance.callAkuminaAPI(endPoint: String, method: String,accessToken: String?, query:
                               Dictionary<String,String>, payLoad: Data? , completionHandler: @escaping (_ success: Bool, _ data: Data? , _ error: Error?) -> Void)
          }catch{
                // Handle exception 
          }
   
## License

AkuminaAuthiOSLib is available under the MIT license. See the LICENSE file for more info.
