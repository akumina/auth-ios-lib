import Foundation
import Rollbar

public final class AkuminaLib {
    
    public init() {
        //        let config: RollbarConfiguration = RollbarConfiguration()
        //                    config.environment = "production"
        //        Rollbar.initWithAccessToken(Constants.ROLLBAR_TOKEN, configuration: config)
        //
        //        Rollbar.info(Constants.ROLLBAR_APP_ID +  " has started ");
    }
    
    public func initRollbar(token: String, config: RollbarConfiguration ) {
        
        Rollbar.initWithAccessToken(token, configuration: config)
        
        Constants.ROLL_BAR = true;
    }
    public func authenticateWithMSALAndMAM(parentViewController: UIViewController, clientDetails: ClientDetails, completionHandler: @escaping (MSALResponse) -> Void) throws {
        do {
            try MSALUtils.instance.initMSAL(parentViewController: parentViewController, clientDetails: clientDetails, withIntune: true,completionHandler: completionHandler)
        }catch {
            throw MSALException.TokenFailedException(error: error)
        }
    }
    public func authenticateWithMSAL(parentViewController: UIViewController, clientDetails: ClientDetails, completionHandler: @escaping (MSALResponse) -> Void) throws {
        do {
            try MSALUtils.instance.initMSAL(parentViewController: parentViewController, clientDetails: clientDetails, withIntune: false,completionHandler: completionHandler)
        }catch {
            throw MSALException.TokenFailedException(error: error)
        }
    }
    
    public func getToken(type: TokenType) throws -> String  {
        
        switch type {
            
        case .GRAPH:
            if(Constants.GRAPH_TOKEN == "" ){
                throw TokenError.tokenNotGeneratedError
            }
            return Constants.GRAPH_TOKEN
            
        case .ACCESS:
            if(AppSettings.getAccount().accessToken == nil) {
                throw TokenError.tokenNotGeneratedError
            }
            return AppSettings.getAccount().accessToken!
        case .SHAREPOINT :
            if(Constants.SHAREPOINT_TOKEN == "") {
                throw TokenError.tokenNotGeneratedError
            }
            return Constants.SHAREPOINT_TOKEN
        }
    }
    
    public func callAkuminaAPI(endPoint: String, method: String, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void ) throws {
        
        let request = try createURLRequest(endPoint: endPoint, method: method, payLoad: nil);
        URLSession.shared.dataTask(with: request, completionHandler: completionHandler);
    }
    
    public func callAkuminaAPI(endPoint: String, method: String, payLoad: Data? , completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void ) throws {
        
        let request = try createURLRequest(endPoint: endPoint, method: method, payLoad: payLoad);
        URLSession.shared.dataTask(with: request, completionHandler: completionHandler);
    }
    
    private func createURLRequest(endPoint: String, method: String, payLoad: Data?) throws  -> URLRequest {
        
        let appAccount = AppSettings.getAccount();
        
        let existingToken = String(appAccount.accessToken ??  "");
        
        guard let token = appAccount.accessToken else {
            throw TokenError.tokenNotFoundError
        }
        
        var request = URLRequest(url: URL(string: endPoint)!);
        
        request.httpMethod = method;
        if(payLoad != nil) {
            request.httpBody = payLoad;
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(token, forHTTPHeaderField: "x-akumina-auth-id")
        
        return request
    }
}


