import Foundation
//import Rollbar

public final class AkuminaLib {
    
    public static let instance = AkuminaLib();
    
    private init() {
        //        let config: RollbarConfiguration = RollbarConfiguration()
        //                    config.environment = "production"
        //        Rollbar.initWithAccessToken(Constants.ROLLBAR_TOKEN, configuration: config)
        //
        //        Rollbar.info(Constants.ROLLBAR_APP_ID +  " has started ");
    }
    
//    public func initRollbar(token: String, config: RollbarConfiguration ) {
        
//        Rollbar.initWithAccessToken(token, configuration: config)
        
//        Constants.ROLL_BAR = true;
//    }
    public func authenticateWithMSALAndMAM(parentViewController: UIViewController, clientDetails: ClientDetails,completionHandler: @escaping (MSALResponse) -> Void, loggingHandler: @escaping (String, Bool) -> Void) throws {
        do {
            try MSALUtils.instance.initMSAL(parentViewController: parentViewController, clientDetails: clientDetails, withIntune: true,completionHandler: completionHandler, loggingHandler: loggingHandler)
        }catch {
            throw MSALException.TokenFailedException(error: error)
        }
    }
    
    public func refreshToken() throws {
        do {
            try MSALUtils.instance.callGraphAPI();
        }catch {
            throw MSALException.TokenFailedException(error: error)
        }
    }
    public func authenticateWithMSAL(parentViewController: UIViewController, clientDetails: ClientDetails, completionHandler: @escaping (MSALResponse) -> Void, loggingHandler: @escaping (String, Bool) -> Void) throws {
        do {
            try MSALUtils.instance.initMSAL(parentViewController: parentViewController, clientDetails: clientDetails, withIntune: false,completionHandler: completionHandler, loggingHandler: loggingHandler)
        }catch {
            throw MSALException.TokenFailedException(error: error)
        }
    }
    public func signOut(completionHandler: @escaping (MSALSignoutResponse) -> Void){
        MSALUtils.instance.signOut(completionHandler: completionHandler)
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
    
    public func callAkuminaAPI(endPoint: String, method: String, accessToken: String?, query:
                               Dictionary<String,String>? , completionHandler: @escaping (_ success: Bool, _ data: Data?, _ error: Error?) -> Void) throws {
        
        let request = try createURLRequest(endPoint: endPoint, method: method, accessToken: accessToken, payLoad: nil,query: query);
       
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
              if let data = data {
                 // Success, call the completion handler with the data
                  completionHandler(true, data, nil)
              } else {
                 // Failure, call the completion handler with nil data
                  completionHandler(false, data, error)
              }
           }
        task.resume()
    }
    
    public func callAkuminaAPI(endPoint: String, method: String,accessToken: String?, query:
                               Dictionary<String,String>, payLoad: Data? , completionHandler: @escaping (_ success: Bool, _ data: Data? , _ error: Error?) -> Void ) throws {
        
        let request = try createURLRequest(endPoint: endPoint, method: method,accessToken: accessToken, payLoad: payLoad, query: query);
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
              if let data = data {
                 // Success, call the completion handler with the data
                  completionHandler(true, data, nil)
              } else {
                 // Failure, call the completion handler with nil data
                  completionHandler(false, nil, error)
              }
           }
           task.resume()
    }
    
    private func createURLRequest(endPoint: String, method: String, accessToken: String?, payLoad: Data? , query:
                                  Dictionary<String,String>?) throws  -> URLRequest {
        
        let appAccount = AppSettings.getAccount();

        let existingToken = String(appAccount.accessToken ??  "");
        
        if  accessToken == nil {
            throw TokenError.tokenNotFoundError
        }
        
        var request : URLRequest;
        
        if( query == nil) {
           request =  URLRequest(url: URL(string: endPoint)!);
        }else {
            request = URLRequest(url: URL(string: queryItems(dictionary: query!, url: endPoint))!);
        }
        
        request.httpMethod = method;
        if(payLoad != nil) {
            request.httpBody = payLoad;
        }
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(appAccount.accessToken, forHTTPHeaderField: "x-akumina-auth-id")
        request.setValue("Bearer " + accessToken!, forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    func queryItems(dictionary: Dictionary<String,String>, url: String ) -> String {
        var components = URLComponents(string: url);
        print(components?.url! as Any)
        components?.queryItems = dictionary.map {
            URLQueryItem(name: $0, value: String(describing: $1))
        }
        return (components?.url?.absoluteString)!
    }
}


