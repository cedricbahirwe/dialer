//
//  FirebaseCRUD.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 17/03/2023.
//

import Foundation
import FirebaseFirestore

enum FBCollection: String {
    case merchants
    case devices
    case users
    case transactions

    var name: String {
#if DEBUG
        return rawValue + "-dev"
#else
        return rawValue
#endif
    }
}

protocol FirebaseCRUD {
    var db: Firestore { get }
}

extension Firestore {
    func collection(_ collection: FBCollection) -> CollectionReference {
        self.collection(collection.name)
    }
}

extension FirebaseCRUD {
//    func createBatches<T: Encodable>(_ elements: [T], in collection: FBCollection) async throws {
//        do {
//            let batch = db.batch()
//
//            try elements.forEach { element throws in
//                let docRef = db.collection(collection).document()
//                try batch.setData(from: element, forDocument: docRef)
//            }
//            try await batch.commit()
//
//        } catch {
//            Log.debug("Could not save \(type(of: elements)): \(error.localizedDescription).")
//            throw error
//        }
//    }

    func create<T: Encodable>(_ element: T, in collection: FBCollection) async throws -> Bool {
        return try await withUnsafeThrowingContinuation { continuation in
            do {
                try db.collection(collection).addDocument(from: element) { error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: true)
                    }
                }
            } catch {
                Log.debug("Could not save \(type(of: element)): \(error.localizedDescription).")
                continuation.resume(throwing: error)
            }
        }
    }

    func getAll<T: Decodable>(in collection: FBCollection) async -> [T] {
        do {
            let querySnapshot = try await db.collection(collection)
                .getDocuments()
            
            return await getAllWithQuery(querySnapshot)
        } catch {
            Log.debug("Can not get \(type(of: Merchant.self)) Error: \(error).")
            return []
        }
    }
    
    func getAllWithQuery<T: Decodable>(_ querySnapshot: QuerySnapshot) async -> [T] {
        
        let result = querySnapshot.documents.compactMap { document -> T? in
            do {
                return try document.data(as: T.self)
            } catch {
                Log.debug("Firestore Decoding error: ", error, querySnapshot.documents.forEach { print($0.data()) } )
                return nil
            }
        }
        return result
    }
    
    func getItemWithID<T: Decodable>(_ itemID: String,
                                     in collection: FBCollection) async -> T? {
        do {
            let snapshot = try await db.collection(collection)
                .document(itemID)
                .getDocument()
            
            let item = try snapshot.data(as: T.self)
            
            return item
        } catch {
            Log.debug("Error getting \(T.self): \(error)")
            return nil
        }
    }
    
    func deleteItemWithID(_ itemID: String,
                          in collection: FBCollection) async throws  {
        try await db.collection(collection)
            .document(itemID)
            .delete()
    }
    
    func updateItemWithID<T: Encodable>(_ itemID: String,
                                        content: T,
                                        in collection: FBCollection) async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                
                try db.collection(collection)
                    .document(itemID)
                    .setData(from: content)
                continuation.resume(returning: true)
            } catch {
                Log.debug("Error updating item: \(error)")
                continuation.resume(throwing: error)
            }
        }
    }
}

