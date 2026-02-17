//
//  File.swift
//  RolePlayKit
//
//  Created by Kashif Hussain on 17/02/26.
//

import Foundation
import CommonCrypto


enum EncodingError: Error {
    case invalidData
}

enum CryptoError: Error {
    case encryptionFailed
    case decryptionFailed
    case invalidKeySize
    case invalidBlockSize
    case unknownError
    case status(code: Int32)
    // Add more error cases as needed
}

enum DecodingError: Error {
    case invalidData
    case invalidDecodedData
}

func getKeyBytes(key: String) -> Data {
    var keyBytes = Data(count: 16)
    let parameterKeyBytes = Array(key.utf8)
    let count = min(parameterKeyBytes.count, keyBytes.count)
    keyBytes.replaceSubrange(0..<count, with: parameterKeyBytes[0..<count])
    return keyBytes
}

func newEncryptValueString(valueStr: String) -> String {
    do {
        guard let plainTextBytes = valueStr.data(using: .utf8) else {
            throw EncodingError.invalidData
        }
        
        let keyBytes = getKeyBytes(key: SwiftUtilityEnvironment.shared.config.encryptionDecryptionKey)
        
        let encryptedBytes = try newEncrypt(plainText: plainTextBytes, key: keyBytes, initialVector: keyBytes)
        return encryptedBytes.base64EncodedString()
    }
    catch {
        print("Error \(error)")
    }
    return ""
}

func newDecryptString(responseStr: String) -> String {
    do {
        guard let encryptedData = Data(base64Encoded: responseStr) else {
            throw DecodingError.invalidData
        }
        
        let keyBytes = getKeyBytes(key:SwiftUtilityEnvironment.shared.config.encryptionDecryptionKey)
        
        let decryptedData = try newDecrypt(encryptedData: encryptedData, key: keyBytes, initialVector: keyBytes)
        
        guard let decryptedText = String(data: decryptedData, encoding: .utf8) else {
            throw DecodingError.invalidDecodedData
        }
        
        return decryptedText
    } catch {
        print("Error: \(error)")
    }
    return ""
}

func newDecrypt(encryptedData: Data, key: Data, initialVector: Data) throws -> Data {
    let algorithm: CCAlgorithm = CCAlgorithm(kCCAlgorithmAES)
    let options: CCOptions = CCOptions(kCCOptionPKCS7Padding)
    
    var decryptedBytes = Data(count: encryptedData.count + kCCBlockSizeAES128)
    var decryptedLength: size_t = 0
    
    let status = key.withUnsafeBytes { keyBytes in
        initialVector.withUnsafeBytes { ivBytes in
            encryptedData.withUnsafeBytes { encryptedBytes in
                decryptedBytes.withUnsafeMutableBytes { decryptedBytes in
                    CCCrypt(
                        CCOperation(kCCDecrypt),
                        algorithm,
                        options,
                        keyBytes.baseAddress,
                        key.count,
                        ivBytes.baseAddress,
                        encryptedBytes.baseAddress,
                        encryptedData.count,
                        decryptedBytes.baseAddress,
                        decryptedBytes.count,
                        &decryptedLength
                    )
                }
            }
        }
    }
    
    
    decryptedBytes.count = decryptedLength
    return decryptedBytes
}


func newEncrypt(plainText: Data, key: Data, initialVector: Data) throws -> Data {
    let algorithm: CCAlgorithm = CCAlgorithm(kCCAlgorithmAES)
    let options: CCOptions = CCOptions(kCCOptionPKCS7Padding)
    
    var encryptedBytes = Data(count: plainText.count + kCCBlockSizeAES128)
    var encryptedLength: size_t = 0
    
    let status = key.withUnsafeBytes { keyBytes in
        initialVector.withUnsafeBytes { ivBytes in
            plainText.withUnsafeBytes { plainTextBytes in
                encryptedBytes.withUnsafeMutableBytes { encryptedBytes in
                    CCCrypt(
                        CCOperation(kCCEncrypt),
                        algorithm,
                        options,
                        keyBytes.baseAddress,
                        key.count,
                        ivBytes.baseAddress,
                        plainTextBytes.baseAddress,
                        plainText.count,
                        encryptedBytes.baseAddress,
                        encryptedBytes.count,
                        &encryptedLength
                    )
                }
            }
        }
    }
    
    encryptedBytes.count = encryptedLength
    return encryptedBytes
}
