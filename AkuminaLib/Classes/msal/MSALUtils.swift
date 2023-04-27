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
    
    var applicationContext : MSALPublicClientApplication?
    var webViewParamaters : MSALWebviewParameters?
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
        self.loggingHandler = loggingHandler;
        self.completionHandler = completionHandler;
        self.parentViewController = parentViewController;
        self.withIntune = withIntune;
        self.clientDetails = clientDetails;
        let authority = try MSALAADAuthority(url: clientDetails.authority)
        let msalConfiguration = MSALPublicClientApplicationConfig(
            clientId: clientDetails.clientId,
            redirectUri: clientDetails.redirectUri,
            authority: authority);
        self.applicationContext = try MSALPublicClientApplication(configuration: msalConfiguration);
        self.initWebViewParams();
        try self.callGraphAPI();
        
    }
    func initWebViewParams() {
        self.webViewParamaters = MSALWebviewParameters(authPresentationViewController: self.parentViewController!)
    }
    private func updateCurrentAccount(account: MSALAccount?) {
        self.currentAccount = account
    }
    public func callGraphAPI() throws {
        
        self.loadCurrentAccount { [self] (account) in
            
            guard let currentAccount = account else {
                callAcquireTokenInteractively();
                return
            }
            self.acquireTokenSilently(currentAccount)
        }
    }
    func callAcquireTokenInteractively() {
        self.acquireTokenInteractively { tokenResult in
            switch tokenResult {
            case .success(let result):
                self.currentAccount =  result.account;
                self.getContentWithToken(result: result);
            case .error(let error):
                let errorMsg = "Unable to acquire MSAL token \(error)"
                self.updateLogging(text: errorMsg, error: true)
                self.completionHandler(MSALResponse(token: "", error: TokenError.customError(errorMsg)))
            }
        }
    }
    func acquireTokenSilently(_ account : MSALAccount!) {
        
        guard let applicationContext = self.applicationContext else { return }
        
        let parameters = MSALSilentTokenParameters(scopes: clientDetails.scopes, account: account)
        
        parameters.forceRefresh = true;
        
        applicationContext.acquireTokenSilent(with: parameters) { (result, error) in
            
            if let error = error {
                
                let nsError = error as NSError
                
                if (nsError.domain == MSALErrorDomain) {
                    
                    if (nsError.code == MSALError.interactionRequired.rawValue) {
                        
                        DispatchQueue.main.async {
                            self.callAcquireTokenInteractively()
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
            self.getContentWithToken(result: result);
        }
    }
    
    func acquireTokenInteractively(completion: @escaping (TokenResult)  -> (Void)) {
        guard let applicationContext = self.applicationContext else { return }
        guard let webViewParameters = self.webViewParamaters else { return }
        let parameters = MSALInteractiveTokenParameters(scopes: clientDetails.scopes, webviewParameters: webViewParameters)
        parameters.loginHint = AppSettings.getAccount().mUPN
        parameters.promptType = .selectAccount
        
        applicationContext.acquireToken(with: parameters) { (result, error) in
            
            if let error = error {
                completion(TokenResult.error(error: error))
                return
            }
            
            guard let result = result else {
                
                completion(TokenResult.error(error: String(describing: "Could not acquire token: No result returne")))
                return
            }
            
            self.accessToken = result.accessToken
            //self.updateLogging(text: "Access token is \(self.accessToken)", error:false);
            completion(TokenResult.success(result: result))
            
        }
        
    }
    func loadCurrentAccount(completion: AccountCompletion? = nil) {
        
        self.postParamenters.removeAll();
        guard let applicationContext = self.applicationContext else { return }
        var appAcc: AppAccount ;
        appAcc =   AppSettings.getAccount();
        if( appAcc.mUPN == nil || appAcc.mUPN == "") {
            self.accessToken = ""
            self.updateCurrentAccount(account: nil)
            completion!(nil)
            return
        }
        do {
            let acc : MSALAccount  = try applicationContext.account(forUsername: appAcc.mUPN!);
            completion!(acc)
            return
        }catch{
            self.updateLogging(text: "Unable to get Account from Cache \(error)", error: true)
            completion!(nil)
        }
    }
    
    func getContentWithToken(result: MSALResult) {
        
        let account: MSALAccount =  result.account;
        self.currentAccount = account;
        let upn = account.username ?? "N?A";
        let aadId = account.identifier!;
        
        let tenantId = result.tenantProfile.tenantId!;
        let authorityURL = result.authority.url;
        
        var  message: String  = "Authentication succeeded for user " + upn + " token =" + result.accessToken;
        
        let firstScope: String = clientDetails.scopes[0];
        var scope = firstScope.replacingOccurrences(of: ".default", with: "");
        let params = Params();
        params.add(key: "resource", value: scope);
        params.add(key: "id_token", value: result.idToken!);
        params.add(key: "access_token", value: result.accessToken)
        Constants.GRAPH_TOKEN = result.accessToken;
        let date:  Date? =  result.expiresOn;
        params.add(key: "expires_on", value: dateFormatter.string(from: date ?? Date() ));
        scope = firstScope.replacingOccurrences(of: "/.default", with: "");
        
        params.add(key: "scope", value: scope);
        
        postParamenters.append(params.values());
        
        self.mAccount = AppSettings.getAccount()
        self.mAccount?.mUPN = upn;
        self.mAccount?.mAADID = aadId;
        self.mAccount?.mTenantID = tenantId;
        self.mAccount?.mAuthority=authorityURL.absoluteString;
        
        
        AppSettings.saveAccount(account: self.mAccount!);
        if (withIntune) {
            IntuneMAMEnrollmentManager.instance().delegate = EnrollmentDelegateClass(viewController: parentViewController!, completionHandler: self.completionHandler)
            IntuneMAMEnrollmentManager.instance().loginAndEnrollAccount(upn);
        }else {
            self.getSharePointAccessTokenAsync();
        }
        self.updateLogging(text: message, error:false);
        
    }
    
    func updateLogging(text : String, error: Bool) {
        self.loggingHandler(text, error)
        if Thread.isMainThread {
            print( text);
        } else {
            DispatchQueue.main.async {
                print( text);
            }
        }
    }
    
    func getSharePointAccessTokenAsync  () -> Void {
        
        guard let applicationContext = self.applicationContext else { return }
        
        let parameters = MSALSilentTokenParameters(scopes: [clientDetails.sharePointURL], account: self.currentAccount!);
        do {
            
            parameters.authority = try  MSALAuthority(url:  clientDetails.authority)
            
            applicationContext.acquireTokenSilent(with: parameters) { (result, error) in
                
                if let error = error {
                    let errorMsg = "Could not acquire sharepoint token silently: \(error)";
                    
//                    UIUtils.showToast(controller: self.parentViewController!, message: errorMsg, seconds: 10)
                    self.completionHandler(MSALResponse(token: "", error: error));
                    self.updateLogging(text: errorMsg,error:true)
                    return
                }
                
                guard let result = result else {
                    
                    let errorMsg = "Could not acquire token: No result returned";
                    
//                    UIUtils.showToast(controller: self.parentViewController!, message: errorMsg, seconds: 10)
                    self.completionHandler(MSALResponse(token: "", error: MSALException.NoResultFound));
                    self.updateLogging(text: errorMsg,error:true)
                    return
                }
                
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
        params.add(key: "expires_on", value: dateFormatter.string(from: date ?? Date() ));
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
            self.completionHandler(MSALResponse(token: "", error: MSALException.JSONError(msg: "Error: Trying to convert model to JSON data")))
            return
        }
        let JSONString = String(data: jsonData, encoding: String.Encoding.ascii)!
        
        updateLogging(text: JSONString, error: false);
        
        let appAccount = AppSettings.getAccount();
        
        let existingToken = String(appAccount.accessToken ??  "");
        
        let postData = JSONString.data(using: .utf8)
        
        var request = URLRequest(url: clientDetails.appManagerURL);
        request.httpMethod = "POST";
        request.httpBody = postData;
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        if(existingToken != "") {
            request.setValue(existingToken, forHTTPHeaderField: "x-akumina-auth-id");
//        }
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                let errMsg = "Error: error calling POST " + self.clientDetails.appManagerURL.description;
                self.updateLogging(text: "Error: " + errMsg, error: true)
                self.completionHandler(MSALResponse(token: "", error: MSALException.HTTPError(msg: errMsg)))
                return
            }
            guard let data = data else {
                let errMsg = "Error: Did not receive data " + self.clientDetails.appManagerURL.description;
                self.updateLogging(text: "Error: " + errMsg, error: true)
                self.completionHandler(MSALResponse(token: "", error: MSALException.HTTPError(msg: errMsg)))
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                let errMsg = "Error: HTTP request failed " + response.debugDescription  + "URL " + self.clientDetails.appManagerURL.description;
                self.updateLogging(text: "Error: " + errMsg, error: true)
                self.completionHandler(MSALResponse(token: "", error: MSALException.HTTPError(msg: errMsg)))
                return
            }
            let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String:AnyObject]
            self.saveToken(json: json!, appAccount: appAccount);
        }.resume();
    }
    
    func saveToken(json: Dictionary<String, AnyObject>, appAccount: AppAccount) {
        let token = json["Data"]
        var acc = AppSettings.getAccount();
        acc.accessToken = (token as! String);
        AppSettings.saveAccount(account: acc);
        self.completionHandler(MSALResponse(token: acc.accessToken ?? ""));
    }
    
    func signOut(completionHandler: @escaping (MSALSignoutResponse) -> Void ) {
            guard let applicationContext = self.applicationContext else { return }
            guard let account = self.currentAccount else { return }
            self.initWebViewParams();
            let signoutParameters = MSALSignoutParameters(webviewParameters: self.webViewParamaters!);
        applicationContext.signout(with: account, signoutParameters: signoutParameters) { success, error in
            completionHandler(MSALSignoutResponse(error: error))
        }
//            applicationContext.signout(with: account, signoutParameters: signoutParameters, completionBlock: {(success, error) in
//
//                if let error = error {
//                    self.updateLogging(text: "Couldn't sign out account with error: \(error)" ,error:true)
//                    return
//                }
//
//                self.updateLogging(text: "Sign out completed successfully", error: false)
//                self.accessToken = ""
//                self.updateCurrentAccount(account: nil)
//            })
            
        }
}
