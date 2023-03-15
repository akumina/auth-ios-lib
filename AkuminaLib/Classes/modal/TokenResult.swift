//
//  TokenResult.swift
//  AkuminaLib
//
//  Created by Mac on 14/03/23.
//

import Foundation
import MSAL

public enum TokenResult {
    
    case success(result: MSALResult)
    case error(error: Any)
}
