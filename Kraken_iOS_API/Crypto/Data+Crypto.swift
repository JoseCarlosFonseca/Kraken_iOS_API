//
//  Data+Crypto.swift
//  Crypto
//
//  Created by Sam Soffes on 4/21/15.
//  Copyright (c) 2015 Sam Soffes. All rights reserved.
//

import Foundation


extension String {
    //de: https://gist.github.com/shmidt/2295b52b1e3289672e2ffafd6ca58c60
    //: ### Base64 encoding a string
    func base64Encoded() -> String? {
        if let data = self.data(using: .utf8) {
            return data.base64EncodedString()
        }
        return nil
    }
    
    //: ### Base64 decoding a string
    func base64Decoded() -> String? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    /// Expanded encoding
    ///
    /// - bytesHexLiteral: Hex string of bytes
    /// - base64: Base64 string
    enum ExpandedEncoding {
        /// Hex string of bytes
        case bytesHexLiteral
        /// Base64 string
        case base64
    }
    
    /// Convert to `Data` with expanded encoding
    ///
    /// - Parameter encoding: Expanded encoding
    /// - Returns: data
    func data(using encoding: ExpandedEncoding) -> Data? {
        switch encoding {
        case .bytesHexLiteral:
            guard self.count % 2 == 0 else { return nil }
            var data = Data()
            var byteLiteral = ""
            for (index, character) in self.enumerated() {
                if index % 2 == 0 {
                    byteLiteral = String(character)
                } else {
                    byteLiteral.append(character)
                    guard let byte = UInt8(byteLiteral, radix: 16) else { return nil }
                    data.append(byte)
                }
            }
            return data
        case .base64:
            return Data(base64Encoded: self)
        }
    }
}

extension Data {

	// MARK: - Digest

	public var md2: Data {
		return digest(Digest.md2)
	}

	public var md4: Data {
		return digest(Digest.md4)
	}

	public var md5: Data {
		return digest(Digest.md5)
	}

	public var sha1: Data {
		return digest(Digest.sha1)
	}

	public var sha224: Data {
		return digest(Digest.sha224)
	}

	public var sha256: Data {
		return digest(Digest.sha256)
	}

	public var sha384: Data {
		return digest(Digest.sha384)
	}

	public var sha512: Data {
		return digest(Digest.sha512)
	}

	private func digest(_ function: ((UnsafeRawPointer, UInt32) -> [UInt8])) -> Data {
		var hash: [UInt8] = []
		withUnsafeBytes { hash = function($0, UInt32(count)) }
		return Data(bytes: hash, count: hash.count)
	}


	// MARK: - HMAC

	public func hmac(key: Data, algorithm: HMAC.Algorithm) -> Data {
		return HMAC.sign(data: self, algorithm: algorithm, key: key)
	}


	// MARK: - Internal

	var hex: String {
		var string = ""

		#if swift(>=3.1)
			enumerateBytes { pointer, index, _ in
				for i in index..<pointer.count {
					string += String(format: "%02x", pointer[i])
				}
			}
		#else
			enumerateBytes { pointer, count, _ in
				for i in 0..<count {
					string += String(format: "%02x", pointer[i])
				}
			}
		#endif

		return string
	}
}
