//
//  Keychain.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 21/10/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import Foundation
import Security

enum KeychainError: Error {
    case status(OSStatus)
}

private typealias KeychainQuery = [String:AnyObject]

struct Keychain {
    
    /// Retrieves data from the keychain.
    ///
    /// :param: identifier The name for the data to retreive.
    ///
    /// :returns: The data or throws an error
    static func get(identifier: String) throws -> Data {
        
        var query = keychainQuery(identifier: identifier)
        query[String(kSecReturnData)] = true as AnyObject?
        query[String(kSecMatchLimit)] = kSecMatchLimitOne
        
        var result: AnyObject?
        
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard let unwrappedResult = result, let data = unwrappedResult as? Data else {
            throw KeychainError.status(status)
        }
        
        return data
    }
    
    /// Stores data in the keychain.
    ///
    /// :param: identifier The name for the data to store.
    /// :param: data The data to store.
    /// :param: accessibility The kSecAttrAccessible value to use, by default this is kSecAttrAccessibleWhenUnlocked.
    static func set(identifier: String, data: Data, accessibility: String = String(kSecAttrAccessibleWhenUnlocked)) throws {
        
        var query = keychainQuery(identifier: identifier)
        SecItemDelete(query as CFDictionary)
        
        query[String(kSecValueData)] = data as AnyObject?
        query[String(kSecAttrAccessible)] = accessibility as AnyObject?
        
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw KeychainError.status(status)
        }
    }
    
    /// Deletes data stored in the keychain.
    ///
    /// :param: identifier The name for the data to remove.
    static func delete(identifier: String) throws {
        let query = keychainQuery(identifier: identifier)
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else {
            throw KeychainError.status(status)
        }
    }
    
    private static func keychainQuery(identifier: String) -> KeychainQuery {
        return [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrAccount as String : identifier as AnyObject,
            kSecAttrService as String : "cc.rapha.rides" as AnyObject,
            kSecAttrSynchronizable as String : true as AnyObject
        ]
    }
}


