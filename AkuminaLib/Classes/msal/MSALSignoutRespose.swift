//
//  MSALSignoutRespose.swift
//  AkuminaLib
//
//  Created by Mac on 27/03/23.
//

import Foundation

public struct MSALSignoutResponse {
    
    public var error: Error?
    
    init(error: Error?) {
        self.error = error
    }
    
}
