//
//  FSCollection.swift
//  LymCar
//
//  Created by 이은재 on 1/13/24.
//

import Firebase

final class FSCollection {
    enum CollectionType {
        case fcmToken, rooms, users
        case chatLogs(id: String)
        case joinTimeStamp(id: String)
    }
    
    static func reference(
        type: CollectionType
    ) -> CollectionReference {
        let db = Firestore.firestore()
        
        switch type {
        case .fcmToken:
            return db.collection("FcmTokens")
        case .rooms:
            return db.collection("Rooms")
        case .users:
            return db.collection("Users")
        case let .chatLogs(id):
            return db.collection("Rooms").document(id).collection("ChatLogs")
        case let .joinTimeStamp(id):
            return db.collection("Rooms").document(id).collection("joinTimeStamp")
        }
    }
}
