//
//  Params.swift
//  akuminaDev
//
//  Created by Mac on 18/02/23.
//

import Foundation

class Params : Codable {
    
    var params = Dictionary<String, String>();
    
    func add(key: String, value: String) {
        params[key] = value;
    }
    
    func clear() {
        params.removeAll();
    }
    
    func values() -> Dictionary<String, String> {
        return self.params;
    }
}
