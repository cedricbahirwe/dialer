//
//  FirebaseCRUD.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 17/03/2023.
//

import Foundation
import FirebaseFirestore

enum CollectionName: String {
    case merchants
    case devices
}

protocol FirebaseCRUD {
    var db: Firestore { get }
}

extension FirebaseCRUD {
    func create<T: Encodable>(_ element: T, in collection: CollectionName) async throws -> Bool {
        return try await withUnsafeThrowingContinuation { continuation in
            do {
                _ = try db.collection(collection.rawValue).addDocument(from: element) { error in
                    
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: true)
                    }
                }
            } catch {
                debugPrint("Could not save \(type(of: element)): \(error.localizedDescription).")
                continuation.resume(throwing: error)
            }
        }
    }
    
    func getAll<T: Decodable>(in collection: CollectionName) async -> [T] {
        do {
            let querySnapshot = try await db.collection(collection.rawValue)
                .getDocuments()
            let result = querySnapshot.documents.compactMap { document -> T? in
                do {
                    return try document.data(as: T.self)
                } catch {
                    debugPrint("Firestore Decoding error: ", error, querySnapshot.documents.forEach { print($0.data()) } )
                    return nil
                }
            }
            return result
        } catch {
            debugPrint("Can not get \(type(of: Merchant.self)) Error: \(error).")
            return []
        }
    }
    
    func getItemWithID<T: Decodable>(_ itemID: String,
                                     in collection: CollectionName) async -> T? {
        do {
            let snapshot = try await db.collection(collection.rawValue)
                .document(itemID)
                .getDocument()
            
            let item = try snapshot.data(as: T.self)
            
            return item
        } catch {
            debugPrint("Error getting \(T.self): \(error)")
            return nil
        }
    }
    
    func deleteItemWithID(_ itemID: String,
                          in collection: CollectionName) async throws  {
        try await db.collection(collection.rawValue)
            .document(itemID)
            .delete()
    }
    
    func updateItemWithID<T: Encodable>(_ itemID: String,
                                        content: T,
                                        in collection: CollectionName) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                
                try db.collection(collection.rawValue)
                    .document(itemID)
                    .setData(from: content)
                
                continuation.resume(returning: true)
            } catch {
                debugPrint("Error updating Merchant: \(error)")
                continuation.resume(throwing: error)
                
            }
        }
    }
}

