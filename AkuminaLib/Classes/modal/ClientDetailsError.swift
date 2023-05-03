//
//  ClientDetailsError.swift
//  AkuminaLib
//
//  Created by Mac on 13/03/23.
//

import Foundation

enum ClientDetailsError: Error {
    case invalidAuthorityURL(url: String)
    case invalidRedirectUri(url: String)
    case invalidSharePoint(url: String)
    case invalidAppMannager(url: String)
}
