import Foundation
import CryptoKit

private let account = "Secrets"
private let service = "Protection"

enum Security {
    static var key: SymmetricKey?
    
    private static var retrieve: SymmetricKey? {
        var item: CFTypeRef?
        
        guard
            
            SecItemCopyMatching(([
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: account,
                kSecAttrService: service,
                kSecUseDataProtectionKeychain: true,
                kSecAttrSynchronizable: kSecAttrSynchronizableAny,
                kSecReturnData: true] as [String: Any]) as CFDictionary, &item) == errSecSuccess,
            
            let data = item as? Data
        else { return nil }
        
        key = .init(data: data)
        return key
    }
    
    private static var generate: SymmetricKey? {
        key = .init(size: .bits256)
        
        guard
            
            SecItemAdd([
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: account,
                kSecAttrService: service,
                kSecUseDataProtectionKeychain: true,
                kSecAttrSynchronizable: true,
                kSecValueData: key!
                    .withUnsafeBytes {
                        Data($0)
                    }] as [String: Any] as CFDictionary, nil) == errSecSuccess
                
        else { return nil }
        
        return key
    }
    
    static func encrypt(data: Data) -> Data {
        (key ?? retrieve ?? generate)
            .flatMap { key in
                try? AES
                    .GCM
                    .seal(data, using: key)
                    .combined
            }
        ?? .init()
    }
    
    static func decrypt(data: Data) -> Data {
        (key ?? retrieve)
            .flatMap { key in
                (try? AES
                    .GCM
                    .SealedBox(combined: data))
                    .flatMap {
                        try? AES
                            .GCM
                            .open($0, using: key)
                    }
            }
        ?? .init()
    }
}
