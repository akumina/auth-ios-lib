//
//  MSALException.swift
//  AkuminaLib
//
//  Created by Mac on 14/03/23.
//

import Foundation

public enum MSALException: Error {
    case TokenFailedException(error: Error)
    case NoResultFound
    case JSONError(msg: String)
    case HTTPError(msg: String)
}
