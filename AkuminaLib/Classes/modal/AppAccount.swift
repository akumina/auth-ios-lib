//
//  AppAccounnt.swift
//  akuminaDev
//
//  Created by Mac on 17/02/23.
//

import Foundation

public struct AppAccount : Codable {
    
    public var mUPN : String? = nil;
    
    public var mAADID: String? = nil;
    
    public var mTenantID : String? = nil;
    
    public var mAuthority: String? = nil;
    
    public var accessToken: String? = nil;
    
    public var pushToken: String?  = nil ;
    
    public var workMail: String? = nil;
    
    public var uuid : String? = nil;
    
    public var oldToken: String? = nil;
    
    init(mUPN: String, mAADID: String, mTenantID: String, mAuthority: String) {
        self.mUPN = mUPN
        self.mAADID = mAADID
        self.mTenantID = mTenantID
        self.mAuthority = mAuthority
    }
    
    public init() {
        if( uuid != nil) {
            uuid = UUID().uuidString
        }
    }

   public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try container.decodeIfPresent(String.self, forKey: .uuid) ?? ""
        if(uuid == "") {
            uuid = UUID().uuidString
        }
        print("UUID =" + (uuid ?? ""));
        mUPN = try container.decodeIfPresent(String.self, forKey: .mUPN) ?? ""
        mAADID = try container.decodeIfPresent(String.self, forKey: .mAADID) ?? ""
        mTenantID = try container.decodeIfPresent(String.self, forKey: .mTenantID) ?? ""
        mAuthority = try container.decodeIfPresent(String.self, forKey: .mAuthority) ?? ""
        accessToken = try container.decodeIfPresent(String.self, forKey: .accessToken) ?? ""
        pushToken = try container.decodeIfPresent(String.self, forKey: .pushToken) ?? ""
        workMail = try container.decodeIfPresent(String.self, forKey: .workMail) ?? ""
        oldToken = try container.decodeIfPresent(String.self, forKey: .oldToken) ?? ""
    }
}
