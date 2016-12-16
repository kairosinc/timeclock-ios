//
//  Keychain.swift
//  Timeclock
//
//  Created by Tom Hutchinson on 21/10/2016.
//  Copyright © 2016 Kairos. All rights reserved.
//

import Foundation
import Security

enum KeychainError: ErrorType {
    case Status(OSStatus)
}

private typealias KeychainQuery = [String:AnyObject]

struct Keychain {
    
    /// Retrieves data from the keychain.
    ///
    /// :param: identifier The name for the data to retreive.
    ///
    /// :returns: The data or throws an error
    static func get(identifier identifier: String) throws -> NSData {
        
        var query = keychainQuery(identifier: identifier)
        query[String(kSecReturnData)] = true
        query[String(kSecMatchLimit)] = String(kSecMatchLimitOne)
        
        var result: NSData?
        let status = withUnsafeMutablePointer(&result) {
            SecItemCopyMatching(query, UnsafeMutablePointer($0))
        }
        
        guard let data = result else {
            throw KeychainError.Status(status)
        }
        
        return data
    }
    
    /// Stores data in the keychain.
    ///
    /// :param: identifier The name for the data to store.
    /// :param: data The data to store.
    /// :param: accessibility The kSecAttrAccessible value to use, by default this is kSecAttrAccessibleWhenUnlocked.
    static func set(identifier identifier: String, data: NSData, accessibility: String = String(kSecAttrAccessibleWhenUnlocked)) throws {
        
        var query = keychainQuery(identifier: identifier)
        SecItemDelete(query)
        
        query[String(kSecValueData)] = data
        query[String(kSecAttrAccessible)] = accessibility
        
        let status = SecItemAdd(query, nil)
        guard status == errSecSuccess else {
            throw KeychainError.Status(status)
        }
    }
    
    /// Deletes data stored in the keychain.
    ///
    /// :param: identifier The name for the data to remove.
    static func delete(identifier identifier: String) throws {
        let query = keychainQuery(identifier: identifier)
        let status = SecItemDelete(query)
        guard status == errSecSuccess else {
            throw KeychainError.Status(status)
        }
    }
    
    private static func keychainQuery(identifier identifier: String) -> KeychainQuery {
        return [
            String(kSecClass) : String(kSecClassGenericPassword),
            String(kSecAttrAccount) : identifier,
            String(kSecAttrService) : "com.kairos.timeclock",
            String(kSecAttrSynchronizable) : true
        ]
    }
}

