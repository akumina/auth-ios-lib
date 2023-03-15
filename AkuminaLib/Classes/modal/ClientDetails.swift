//
//  ClientDetails.swift
//  AkuminaLib
//
//  Created by Mac on 13/03/23.
//

import Foundation

public struct ClientDetails {
    
    var authority: URL
    var clientId: String
    var redirectUri: String
    var scopes: [String]
    var sharePointURL: String
    var appManagerURL: URL
    var tenantId: String
    public init(authority: String, clientId: String, redirectUri: String, scopes: [String],
                sharePointScope: String,appManagerURL: String, tenantId: String) throws {
        guard let authorityURL  = URL(string:authority) else {
            throw ClientDetailsError.invalidAuthorityURL(url: authority);
        }
        
        if(!UIApplication.shared.canOpenURL(authorityURL)){
            throw ClientDetailsError.invalidAuthorityURL(url: authority);
        }
        
        guard let appManager  = URL(string:appManagerURL) else {
            throw ClientDetailsError.invalidAppMannager(url: appManagerURL)
        }
        if(!UIApplication.shared.canOpenURL(appManager)){
            throw ClientDetailsError.invalidAppMannager(url: appManagerURL)
        }
        self.authority = authorityURL
        self.clientId = clientId;
        self.redirectUri = redirectUri;
        self.scopes = scopes;
        self.sharePointURL = sharePointScope;
        self.appManagerURL =  appManager;
        self.tenantId = tenantId
    }
    
    public init() {
        self.authority = URL(string: "http://localhost")!
        self.clientId = ""
        self.redirectUri = ""
        self.scopes = []
        self.sharePointURL = "";
        self.appManagerURL = URL(string: "http://localhost")!
        self.tenantId = ""
    }
}
