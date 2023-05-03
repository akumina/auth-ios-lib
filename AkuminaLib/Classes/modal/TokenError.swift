//
//  TokenError.swift
//  AkuminaLib
//
//  Created by Mac on 25/03/23.
//

import Foundation

enum TokenError: Error {
    case tokenNotGeneratedError
    case tokenNotFoundError
    case customError(String)
}
