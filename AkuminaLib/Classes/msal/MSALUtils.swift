//
//  MSALUtils.swift
//  AkuminaLib
//
//  Created by Mac on 13/03/23.
//

import Foundation
import MSAL
import IntuneMAMSwift

class MSALUtils {
    
    static let instance = MSALUtils();
    
    //    var applicationContext : MSALPublicClientApplication?
    //    var webViewParamaters : MSALWebviewParameters?
    var parentViewController: UIViewController?;
    var postParamenters = [Dictionary<String, String>]();
    
    var accessToken = String()
    var mAccount: AppAccount?;
    var currentAccount: MSALAccount?
    
    var clientDetails: ClientDetails;
    var withIntune: Bool = false;
    
    var completionHandler: (MSALResponse) -> Void  = {_ in }
    
    let dateFormatter = DateFormatter();
    var loggingHandler: (String, Bool) -> Void = {_,_ in }
    
    typealias AccountCompletion = (MSALAccount?) -> Void
    
    private init(){
        clientDetails = ClientDetails();
        dateFormatter.dateFormat = "dd MMM yyyy HH:mm:ss Z"
    }
    
    public func initMSAL(parentViewController: UIViewController, clientDetails: ClientDetails, withIntune: Bool, completionHandler: @escaping (MSALResponse) -> Void , loggingHandler: @escaping (String, Bool) -> Void) throws {
        var  version = Bundle(for: AkuminaLib.self).infoDictionary!["CFBundleShortVersionString"]!
        var build = Bundle(for: AkuminaLib.self).infoDictionary!["CFBundleVersion"]!
        self.clientDetails = clientDetails;
        self.loggingHandler = loggingHandler;
        self.updateLogging(text: "Loading Akumina Lib Version  \(version) and Build \(build)" , error: false);
        version =  MSALPublicClientApplication.sdkVersion
        self.updateLogging(text: "Loading MSAL Version \(version)" , error: false);
        self.updateLogging(text: "Sign-In started for user \(clientDetails.userId) to MAM \(withIntune)" , error: false);
        self.postParamenters = [Dictionary<String, String>]();
        self.completionHandler = completionHandler;
        self.parentViewController = parentViewController;
        self.withIntune = withIntune;
        let authority = try MSALAADAuthority(url: clientDetails.authority)
                let msalConfiguration = MSALPublicClientApplicationConfig(
                    clientId: clientDetails.clientId,
                    redirectUri: clientDetails.redirectUri,
                    authority: authority);
//        let config = MSALPublicClientApplicationConfig(clientId: clientDetails.clientId)
        let application = try? MSALPublicClientApplication(configuration: msalConfiguration);
        //        self.applicationContext = try MSALPublicClientApplication(configuration: msalConfiguration);
        //        self.initWebViewParams();
        try self.callGraphAPI(app: application!);
        
    }
    
    
    func initWebViewParams()  -> MSALWebviewParameters{
        return  MSALWebviewParameters(authPresentationViewController: self.parentViewController!)
    }
    private func updateCurrentAccount(account: MSALAccount?) {
        self.currentAccount = account
        self.accessToken = ""
    }
    public func callGraphAPI(app: MSALPublicClientApplication) throws {
        
        self.loadCurrentAccount(app: app,completion: {
            (account) in
            guard let currentAccount = account else {
                self.callAcquireTokenInteractively(app: app);
                return
                
            }
            self.acquireTokenSilently(app: app, currentAccount)
        })
        
    }
    func callAcquireTokenInteractively(app: MSALPublicClientApplication) {
        self.acquireTokenInteractively(app: app, completion:  { tokenResult in
            switch tokenResult {
            case .success(let result):
                self.currentAccount =  result.account;
                self.getContentWithToken(app: app, result: result)
            case .error(let error):
                let errorMsg = "Unable to acquire MSAL token \(error)"
                self.updateLogging(text: errorMsg, error: true)
                self.completionHandler(MSALResponse(token: "", error: TokenError.customError(errorMsg)))
            }
        })
    }
    func acquireTokenSilently(app: MSALPublicClientApplication,_ account : MSALAccount!) {
        
        //        guard let applicationContext = self.applicationContext else { return }
        
        let parameters = MSALSilentTokenParameters(scopes: clientDetails.scopes, account: account)
        
        self.updateLogging(text: "acquireTokenSilently",error:false);
        
        parameters.forceRefresh = true;
        
        app.acquireTokenSilent(with: parameters) { (result, error) in
            
            if let error = error {
                
                let nsError = error as NSError
                
                if (nsError.domain == MSALErrorDomain) {
                    
                    if (nsError.code == MSALError.interactionRequired.rawValue) {
                        
                        DispatchQueue.main.async {
                            self.callAcquireTokenInteractively(app: app)
                        }
                        return
                    }else {
                        self.completionHandler(MSALResponse(token: "", error: error))
                    }
                }
                
                self.updateLogging(text: "Could not acquire token silently: \(error)",error:true)
                self.completionHandler(MSALResponse(token: "", error: error))
                return
            }
            
            guard let result = result else {
                
                self.updateLogging(text: "Could not acquire token: No result returned",error:false)
                self.completionHandler(MSALResponse(token: "", error: MSALException.NoResultFound))
                return
            }
            
            self.accessToken = result.accessToken
            self.updateLogging(text: "Refreshed Access token is \(self.accessToken)", error: false)
            self.getContentWithToken(app:app,result: result);
        }
    }
    
    func acquireTokenInteractively(app: MSALPublicClientApplication, completion: @escaping (TokenResult)  -> (Void)) {
        
        //        guard let applicationContext = self.applicationContext else { return }
        let webViewParameters = self.initWebViewParams();
        let parameters = MSALInteractiveTokenParameters(scopes: clientDetails.scopes, webviewParameters: webViewParameters)
        parameters.loginHint = clientDetails.userId
        parameters.promptType = .promptIfNecessary
        
        self.updateLogging(text: "->> acquireTokenInteractively \(String(describing: AppSettings.getAccount().mUPN)) ",error:false);
        
        app.acquireToken(with: parameters) { (result, error) in
            
            if let error = error {
                completion(TokenResult.error(error: error))
                return
            }
            
            guard let result = result else {
                
                completion(TokenResult.error(error: "Could not acquire token: No result return \(String(describing: parameters.loginHint))"))
                return
            }
            
            self.accessToken = result.accessToken
            self.updateLogging(text: "Access token is \(self.accessToken) \(String(describing: parameters.loginHint)) ", error:false);
            completion(TokenResult.success(result: result))
            
        }
        
    }
    func loadCurrentAccount(app: MSALPublicClientApplication, completion: AccountCompletion? = nil) {
        
        self.postParamenters.removeAll();
        //        guard let applicationContext = self.applicationContext else { return }
        var appAcc: AppAccount ;
        appAcc =   AppSettings.getAccount();
        if( appAcc.mUPN == nil || appAcc.mUPN == "" ) {
            self.updateLogging(text: "No User found in app cache", error: false);
            self.accessToken = ""
            self.updateCurrentAccount(account: nil)
            completion!(nil)
            return
        }else {
            if(appAcc.mUPN == clientDetails.userId && appAcc.mAuthority == clientDetails.authority.absoluteString ) {
                self.updateLogging(text: "Welcome back ", error: false);
                do {
                    let acc : MSALAccount  = try app.account(forIdentifier: appAcc.uuid ?? clientDetails.userId);
                    completion!(acc)
                    return
                }catch{
                    self.updateLogging(text: "Unable to get Account from Cache \(error)", error: true)
                    completion!(nil)
                }
            }else {
                self.updateLogging(text: "Different user old user \(String(describing: appAcc.mUPN)) new user \(clientDetails.userId)", error: false);
                //                AppSettings.clearAll();
                self.updateCurrentAccount(account: nil)
                completion!(nil);
            }
        }
        
    }
    
    func getContentWithToken(app: MSALPublicClientApplication,result: MSALResult) {
        
        let account: MSALAccount =  result.account;
        self.currentAccount = account;
        let upn = account.username ?? "N?A";
        let aadId = account.identifier!;
        
        let tenantId = result.tenantProfile.tenantId!;
        let authorityURL = result.authority.url;
        
        let  message: String  = "Authentication succeeded for user " + upn + " token =" + result.accessToken;
        
        let firstScope: String = clientDetails.scopes[0];
        var scope = firstScope.replacingOccurrences(of: ".default", with: "");
        let params = Params();
        params.add(key: "resource", value: scope);
        params.add(key: "id_token", value: result.idToken!);
        params.add(key: "access_token", value: result.accessToken)
        Constants.GRAPH_TOKEN = result.accessToken;
        let date:  Date? =  result.expiresOn;
        params.add(key: "expires_on", value: ((date!.millisecondsSince1970 / 1000).description));
        scope = firstScope.replacingOccurrences(of: "/.default", with: "");
        
        params.add(key: "scope", value: scope);
        
        postParamenters.append(params.values());
        
        self.mAccount = AppSettings.getAccount()
        self.mAccount?.mUPN = upn;
        self.mAccount?.mAADID = aadId;
        self.mAccount?.mTenantID = tenantId;
        self.mAccount?.mAuthority=authorityURL.absoluteString;
        self.mAccount?.uuid = result.account.identifier;
        
        
        AppSettings.saveAccount(account: self.mAccount!);
        if (withIntune) {
            let delegate =  EnrollmentDelegateClass(viewController: parentViewController!,app: app, completionHandler: self.completionHandler,loggingHandler: self.loggingHandler);
            let manager: IntuneMAMEnrollmentManager = IntuneMAMEnrollmentManager.instance();
            
            manager.delegate = delegate
            
            manager.loginAndEnrollAccount(account: account);
            
        }else {
            self.getSharePointAccessTokenAsync(app: app);
        }
        self.updateLogging(text: message, error:false);
        
    }
    
    func updateLogging(text : String, error: Bool) {
        self.loggingHandler(text + " ->  User is \(clientDetails.userId) @ \(Date().timeIntervalSince1970 * 1000 )" , error)
        if Thread.isMainThread {
            print( text);
        } else {
            DispatchQueue.main.async {
                print( text);
            }
        }
    }
    
    
    func getSharePointAccessTokenAsync  (app: MSALPublicClientApplication) -> Void {
        
        //        guard let applicationContext = self.applicationContext else { return }
        
        let parameters = MSALSilentTokenParameters(scopes: [clientDetails.sharePointURL], account: self.currentAccount!);
        do {
            
            parameters.authority = try  MSALAuthority(url:  clientDetails.authority)
            
            app.acquireTokenSilent(with: parameters) { (result, error) in
                
                if let error = error {
                    let errorMsg = "Could not acquire sharepoint token silently: \(error)";
                    
                    //                    UIUtils.showToast(controller: self.parentViewController!, message: errorMsg, seconds: 10)
                    self.completionHandler(MSALResponse(token: "", error: error));
                    self.updateLogging(text: errorMsg,error:true)
                    return
                }
                
                guard let result = result else {
                    
                    let errorMsg = "Could not acquire sharepoint token: No result returned";
                    
                    //                    UIUtils.showToast(controller: self.parentViewController!, message: errorMsg, seconds: 10)
                    self.completionHandler(MSALResponse(token: "", error: MSALException.NoResultFound));
                    self.updateLogging(text: errorMsg,error:true)
                    return
                }
                self.updateLogging(text: "Got Sharepoint result \(result.accessToken)", error: false);
                
                self.getAkuminaToken(result: result);
            }
            
        }catch {
            let errorMsg = "Could not acquire sharepoint token silently: \(error)";
            
            self.completionHandler(MSALResponse(token: "", error: error));
            self.updateLogging(text: errorMsg,error:true)
        }
    }
    
    func getAkuminaToken(result: MSALResult) {
        
        let params = Params();
        params.add(key: "resource", value: clientDetails.sharePointURL);
        params.add(key: "id_token", value: result.idToken!);
        params.add(key:"access_token",value: result.accessToken);
        Constants.SHAREPOINT_TOKEN = result.accessToken
        let date:  Date? =  result.expiresOn;
        params.add(key: "expires_on", value: ((date!.millisecondsSince1970 / 1000).description));
        let firstScope: String = clientDetails.sharePointURL;
        var scope = firstScope.replacingOccurrences(of: ".default", with: "");
        scope = firstScope.replacingOccurrences(of: "/.default", with: "");
        params.add(key: "scope", value: scope);
        self.postParamenters.append(params.values());
        self.callAkuminaPreAuth();
    }
    
    
    func callAkuminaPreAuth () {
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self.postParamenters, options: []) else
        {
            print("Error: Trying to convert model to JSON data")
            self.completionHandler(MSALResponse(token: "", error: MSALException.JSONError(msg: "callAkuminaPreAuth Error: Trying to convert model to JSON data")))
            return
        }
        let JSONString = String(data: jsonData, encoding: String.Encoding.ascii)!
        
        updateLogging(text: JSONString, error: false);
        
        let appAccount = AppSettings.getAccount();
        
        let postData = JSONString.data(using: .utf8)
        
        var request = URLRequest(url: clientDetails.appManagerURL);
        
        self.updateLogging(text: "Executing App Manager URL  \(clientDetails.appManagerURL)", error: false);
        request.httpMethod = "POST";
        request.httpBody = postData;
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if (appAccount.accessToken != "") {
            if(appAccount.oldToken != "") {
                if(appAccount.oldToken != appAccount.accessToken) {
                    request.setValue(appAccount.oldToken, forHTTPHeaderField: "x-akumina-auth-id");
                    self.loggingHandler("App Manager URL called with x-akumina-auth-id " + (appAccount.oldToken ?? "Empty Header"), false);
                }
            }
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                let errMsg = "Error calling POST " + self.clientDetails.appManagerURL.description + "\(String(describing: error))";
                self.updateLogging(text: "callAkuminaPreAuth : " + errMsg, error: true)
                self.completionHandler(MSALResponse(token: "", error: MSALException.HTTPError(msg: errMsg)))
                return
            }
            guard let data = data else {
                let errMsg = "Error: Did not receive data " + self.clientDetails.appManagerURL.description;
                self.updateLogging(text: "callAkuminaPreAuth : " + errMsg, error: true)
                self.completionHandler(MSALResponse(token: "", error: MSALException.HTTPError(msg: errMsg)))
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                let errMsg = "Error: HTTP request failed " + response.debugDescription  + "URL " + self.clientDetails.appManagerURL.description;
                self.updateLogging(text: "callAkuminaPreAuth :" + errMsg, error: true)
                self.completionHandler(MSALResponse(token: "", error: MSALException.HTTPError(msg: errMsg)))
                return
            }
            let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String:AnyObject]
            self.saveToken(json: json!, appAccount: appAccount);
        }.resume();
    }
    
    func saveToken(json: Dictionary<String, AnyObject>, appAccount: AppAccount) {
        let token = (json["Data"] as! String)
        var acc = AppSettings.getAccount();
        updateLogging(text: "Got Akumina Token for user \(clientDetails.userId) Token \(token)", error: false);
        acc.oldToken = acc.accessToken;
        acc.accessToken = token;
        AppSettings.saveAccount(account: acc);
        self.completionHandler(MSALResponse(token: acc.accessToken ?? ""));
    }
    
    func signOut(completionHandler: @escaping (MSALSignoutResponse) -> Void ) {
        //        guard let applicationContext = self.applicationContext else { return }
        let config = MSALPublicClientApplicationConfig(clientId: clientDetails.clientId)
        let application = try? MSALPublicClientApplication(configuration: config);
        guard let account = self.currentAccount else { return }
        let webViewParams =  self.initWebViewParams();
        let signoutParameters = MSALSignoutParameters(webviewParameters: webViewParams);
        signoutParameters.signoutFromBrowser = false
        
        if (self.withIntune) {
            self.updateLogging(text: "\(self.clientDetails.userId) -> deRegisterAndUnenrollAccount ", error: false)
        }
        application!.signout(with: account, signoutParameters: signoutParameters) { success, error in
            completionHandler(MSALSignoutResponse(error: error))
            self.updateCurrentAccount(account: nil);
        }
    }
    
    public func refreshToken() throws {
        let config = MSALPublicClientApplicationConfig(clientId: clientDetails.clientId)
        let application = try? MSALPublicClientApplication(configuration: config);
        try  self.callGraphAPI(app: application!);
    }
}
