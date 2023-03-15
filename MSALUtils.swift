//
//  MSALUtils.swift
//  AkuminaLib
//
//  Created by Mac on 13/03/23.
//

import Foundation
import MSAL

class MSALUtils {
    
    static let instance = MSALUtils();
    
    var applicationContext : MSALPublicClientApplication?
    var webViewParamaters : MSALWebviewParameters?
    var parentViewController: UIViewController?;
    var postParamenters = [Dictionary<String, String>]();
    
    var accessToken = String()
    var mAccount: AppAccount?;
    var currentAccount: MSALAccount?
    
    typealias AccountCompletion = (MSALAccount?) -> Void
    var clientDetails: ClientDetails;
    
    private init(){}
    
    public func initMSAL(parentViewController: UIViewController, clientDetails: ClientDetails) throws {
        self.parentViewController = parentViewController;
        self.clientDetails = clientDetails;
        let authority = try MSALAADAuthority(url: clientDetails.authority)
        let msalConfiguration = MSALPublicClientApplicationConfig(
            clientId: clientDetails.clientId,
            redirectUri: clientDetails.redirectUri,
            authority: authority);
        self.applicationContext = try MSALPublicClientApplication(configuration: msalConfiguration);
        self.initWebViewParams(parentViewController: parentViewController);
        try self.callGraphAPI();
        
    }
    func initWebViewParams(parentViewController: UIViewController) {
        self.webViewParamaters = MSALWebviewParameters(authPresentationViewController: parentViewController)
    }
    private func updateCurrentAccount(account: MSALAccount?) {
        self.currentAccount = account
    }
    private func callGraphAPI() throws {
        
        self.loadCurrentAccount { [self] (account) in
            
            guard let currentAccount = account else {
                
                self.acquireTokenInteractively { tokenResult in
                    switch tokenResult {
                    case .success(let result):
                        self.getContentWithToken(result: result);
                    case .error(let error):
                        throw MSALException.TokenFailedException(error: error)
                    }
                }
                return
            }
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
                //                self.updateLogging(text: "Could not acquire token: \(error)",error:true)
                //                self.showError();
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
        if( appAcc.mUPN == "") {
            self.accessToken = ""
            self.updateCurrentAccount(account: nil)
            completion!(nil)
        }
        do {
            let acc : MSALAccount  = try applicationContext.account(forUsername: appAcc.mUPN!);
            completion!(acc)
        }catch{
            completion!(nil)
        }
    }
}
