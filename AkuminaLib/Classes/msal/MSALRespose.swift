//
//  MSALResult.swift
//  AkuminaLib
//
//  Created by Mac on 14/03/23.
//

import Foundation

public struct MSALResponse {
    
    public var token: String
    public var error: Error? = nil
    
    public init(token: String, error: Error) {
        self.token = token
        self.error = error
    }
    public init(token: String) {
        self.token = token
        self.error = nil
    }
    public init() {
        self.token = ""
        self.error = nil
    }
}
