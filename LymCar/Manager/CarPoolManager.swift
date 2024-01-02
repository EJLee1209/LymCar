//
//  CarPoolManager.swift
//  LymCar
//
//  Created by 이은재 on 12/25/23.
//

import FirebaseFirestore
import FirebaseAuth
import CoreLocation

protocol CarPoolManagerType {
    /// 유저가 참여중인 카풀 리스트 리스너 등록
    func subscribeUserCarPool(completion: @escaping([CarPool]) -> Void)
    
    /// 카풀 리스너 등록
    func subscribeCarPool(roomId: String, completion: @escaping(FirebaseNetworkResult<CarPool>) -> Void)
    
    /// 카풀 리스트 가져오기
    func fetchCarPool(gender: String) async -> [CarPool]
    
    /// 카풀 생성
    func create(
        user: User,
        departurePlaceName: String,
        destinationPlaceName: String,
        departurePlaceCoordinate: CLLocationCoordinate2D,
        destinationCoordinate: CLLocationCoordinate2D,
        departureDate: Date,
        genderOption: Gender,
        maxPersonCount: Int
    ) -> FirebaseNetworkResult<CarPool>
    
    /// 카풀 참여
    func join(
        user: User,
        carPool: CarPool
    ) async -> FirebaseNetworkResult<CarPool>
    
    /// 카풀 퇴장
    func exit(
        user: User,
        roomId: String
    ) async -> FirebaseNetworkResult<String>
    
    /// 메세지 전송
    @discardableResult
    func sendMessage(
        sender: User,
        roomId: String,
        text: String,
        isSystemMsg: Bool
    ) -> FirebaseNetworkResult<Message>
    
    /// 새 메세지 리스너 등록
    func subscribeNewMessages(
        roomId: String,
        completion: @escaping([WrappedMessage]) -> Void
    )
    
    /// 이전 메세지 가져오기
    func fetchMessages(
        roomId: String
    ) async -> [WrappedMessage]
    
    /// 카풀 마감
    func deactivate(roomId: String) async -> FirebaseNetworkResult<String>
    
    /// 메세지 리스너 제거
    func removeMessageListener()
    
    func removeCarPoolListener()
    
    /// 유저 카풀 리스너 제거
    func removeUserCarPoolListener()
    
    func resetPageProperties()
}

final class CarPoolManager: CarPoolManagerType {
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    private var messageListenerRegistration: ListenerRegistration?
    private var userCarPoolListenerRegistration: ListenerRegistration?
    private var carPoolListenerRegistration: ListenerRegistration?
    
    private var startDoc: DocumentSnapshot?
    private var lastDoc: DocumentSnapshot?
    private var endPaging: Bool = false
    private var limit: Int = 20
    
    func subscribeUserCarPool(completion: @escaping([CarPool]) -> Void) {
        guard let uid = auth.currentUser?.uid else {
            return
        }
        
        userCarPoolListenerRegistration = db.collection("Rooms")
            .whereField("participants", arrayContains: uid)
            .order(by: "departureDate")
            .addSnapshotListener { snapshot, error in
                DispatchQueue.main.async {
                    guard let documents = snapshot?.documents else {
                        return
                    }
                    
                    do {
                        let carPoolList = try documents.map { try $0.data(as: CarPool.self) }
                        completion(carPoolList)
                        print("DEBUG: user car pool!")
                    } catch {
                        print("DEBUG: Fail to subscribeUserCarPool with erro \(error.localizedDescription)")
                    }
                }
            }
    }
    
    func subscribeCarPool(roomId: String, completion: @escaping (FirebaseNetworkResult<CarPool>) -> Void) {
        guard let uid = auth.currentUser?.uid else {
            return
        }
        
        carPoolListenerRegistration = db.collection("Rooms")
            .whereField("id", isEqualTo: roomId)
            .addSnapshotListener({ snapshot, error in
                DispatchQueue.main.async {
                    guard let document = snapshot?.documents.first else {
                        completion(.failure(errorMessage: "존재하지 않는 채팅방입니다"))
                        return
                    }
                    
                    do {
                        let carPool = try document.data(as: CarPool.self)
                        completion(.success(response: carPool))
                    } catch {
                        completion(.failure(errorMessage: error.localizedDescription))
                    }
                }
            })
    }
    
    func fetchCarPool(gender: String) async -> [CarPool] {
        do {
            let querySnapshot = try await db.collection("Rooms")
                .order(by: "departureDate")
                .whereField("departureDate", isGreaterThanOrEqualTo: Date())
                .whereField("genderOption", in: [gender, Gender.none.rawValue])
                .whereField("isActivate", isEqualTo: true)
                .order(by: "createdAt")
                .getDocuments()
            
            return try querySnapshot.documents
                .map { try $0.data(as: CarPool.self) }
        } catch {
            print("DEBUG: Failed to fetchCarPool with error \(error.localizedDescription)")
            return []
        }
    }
    
    func join(
        user: User,
        carPool: CarPool
    ) async -> FirebaseNetworkResult<CarPool> {
        
        if carPool.participants.contains(user.uid) { // 이미 참여중인 방
            return .success(response: carPool)
        }
        
        let roomRef = db.collection("Rooms").document(carPool.id)
        
        do {
            let transactionResult = try await db.runTransaction { transaction, errorPointer in
                let roomDocument: DocumentSnapshot
                
                do {
                    try roomDocument = transaction.getDocument(roomRef)
                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    return nil
                }
                
                if !roomDocument.exists {
                    let error = NSError(
                        domain: "AppErrorDomain",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "존재하지 않는 채팅방입니다"
                        ]
                    )
                    errorPointer?.pointee = error
                    return nil
                }
                
                var room: CarPool
                do {
                    room = try roomDocument.data(as: CarPool.self)
                } catch let decodingError as NSError {
                    errorPointer?.pointee = decodingError
                    return nil
                }
                
                if room.participants.contains(user.uid) {
                    return room
                }
                
                if !room.isActivate {
                    let error = NSError(
                        domain: "AppErrorDomain",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "마감된 채팅방입니다"
                        ]
                    )
                    errorPointer?.pointee = error
                    
                    return nil
                }
                
                if room.personCount >= room.maxPersonCount {
                    let error = NSError(
                        domain: "AppErrorDomain",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "채팅방 인원이 초과됐습니다"
                        ]
                    )
                    errorPointer?.pointee = error
                    
                    return nil
                }
                
                room.personCount += 1
                room.participants.append(user.uid)
                
                let updateDict: [String: Any] = [
                    "personCount" : room.personCount,
                    "participants": room.participants
                ]
                
                transaction.updateData(
                    updateDict,
                    forDocument: roomRef
                )
                
                return room
            }
            
            let updatedCarPool = transactionResult as! CarPool
            sendMessage(sender: user, roomId: carPool.id, text: "- \(user.name) 님이 입장했습니다 -", isSystemMsg: true)
            
            Task {
                var roomIds = await getUserCarPoolIds()
                roomIds.append(carPool.id)
                try await db.collection("FcmTokens").document(user.uid).updateData(["roomIds": roomIds])
            }
            
            return .success(response: updatedCarPool)
            
        } catch {
            print("DEBUG: Transaction failed with error \(error)")
            return .failure(errorMessage: error.localizedDescription)
        }
        
    }
    
    func create(
        user: User,
        departurePlaceName: String,
        destinationPlaceName: String,
        departurePlaceCoordinate: CLLocationCoordinate2D,
        destinationCoordinate: CLLocationCoordinate2D,
        departureDate: Date,
        genderOption: Gender,
        maxPersonCount: Int
    ) -> FirebaseNetworkResult<CarPool> {
        let ref = db.collection("Rooms").document()
        
        let departurePlace = Location(
            placeName: departurePlaceName,
            latitude: departurePlaceCoordinate.latitude,
            longitude: departurePlaceCoordinate.longitude
        )
        let destination = Location(
            placeName: destinationPlaceName,
            latitude: destinationCoordinate.latitude,
            longitude: destinationCoordinate.longitude
        )
        
        let carPool = CarPool(
            id: ref.documentID,
            departurePlace: departurePlace,
            destination: destination,
            departureDate: departureDate,
            genderOption: genderOption.rawValue,
            participants: [user.uid],
            maxPersonCount: maxPersonCount
        )
        
        do {
            try ref.setData(from: carPool)
            sendMessage(sender: user, roomId: carPool.id, text: "- \(user.name)님이 입장했습니다 -", isSystemMsg: true)
            
            Task {
                var roomIds = await getUserCarPoolIds()
                roomIds.append(carPool.id)
                try await db.collection("FcmTokens").document(user.uid).updateData(["roomIds": roomIds])
            }
            
            return .success(response: carPool)
        } catch {
            return .failure(errorMessage: "카풀방을 생성하는데 실패했습니다. 잠시 후 다시 시도해주세요")
        }
    }
    
    func exit(
        user: User,
        roomId: String
    ) async -> FirebaseNetworkResult<String> {
        
        let roomRef = db.collection("Rooms").document(roomId)
        
        do {
            let _ = try await db.runTransaction { transaction, errorPointer in
                
                let roomDocument: DocumentSnapshot
                do {
                    try roomDocument = transaction.getDocument(roomRef)
                } catch let fetchError as NSError {
                    errorPointer?.pointee = fetchError
                    return nil
                }
                let room: CarPool
                do {
                    room = try roomDocument.data(as: CarPool.self)
                } catch let decodingError as NSError {
                    errorPointer?.pointee = decodingError
                    return nil
                }
                
                if room.personCount == 1 {
                    // 방 삭제
                    transaction.deleteDocument(roomRef)
                    
                    return nil
                }
                
                let updateDict: [String: Any] = [
                    "personCount": room.personCount - 1,
                    "participants": room.participants.filter { $0 != user.uid }
                ]
                transaction.updateData(updateDict, forDocument: roomRef)
                return nil
            }
            
            sendMessage(sender: user, roomId: roomId, text: "- \(user.name)님이 나갔습니다 -", isSystemMsg: true)
            
            let roomIds = await getUserCarPoolIds()
            let newRoomIds = roomIds.filter { $0 != roomId }
            try await db.collection("FcmTokens").document(user.uid).updateData(["roomIds": newRoomIds])
            
            return .success(response: "")
        } catch {
            return .failure(errorMessage: error.localizedDescription)
        }
        
    }
    
    func getUserCarPoolIds() async -> [String] {
        guard let uid = auth.currentUser?.uid else { return [] }
        
        do {
            let snapshot = try await db.collection("FcmTokens").document(uid).getDocument()
            
            guard let data = snapshot.data() else {
                return []
            }
            let roomIds = data["roomIds"] as! [String]
            
            return roomIds
        } catch {
            print("DEBUG: Fail to getUserCarPoolIds with error \(error.localizedDescription)")
            
            return []
        }
    }
    
    
    func deactivate(roomId: String) async -> FirebaseNetworkResult<String> {
        do {
            try await db.collection("Rooms")
                .document(roomId)
                .updateData(["isActivate": false])
            
            return .success(response: "- 카풀이 마감되었습니다 -")
        } catch {
            return .failure(errorMessage: "카풀을 마감하던 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요")
        }
    }
    
    @discardableResult
    func sendMessage(
        sender: User,
        roomId: String,
        text: String,
        isSystemMsg: Bool
    ) -> FirebaseNetworkResult<Message> {
        let ref = db.collection("Rooms")
            .document(roomId)
            .collection("ChatLogs")
            .document()
        
        let message = Message(
            id: ref.documentID,
            roomId: roomId,
            text: text,
            sender: sender,
            isSystemMsg: isSystemMsg
        )
        
        /// 채팅방에 참여 중인 사용자의 fcmToken 값을 가져와서 push 전송
        Task {
            let tokens = await getParticipantsTokens(roomId: roomId)
            
            for token in tokens {
                let pushMessage = PushMessage(fcmToken: token, from: sender.name, msg: text)
                await sendPush(pushMessage)
            }
        }
        
        do {
            try ref.setData(from: message)
            return .success(response: message)
        } catch {
            return .failure(errorMessage: "메세지 전송 실패")
        }
    }
    
    func getParticipantsTokens(roomId: String) async -> [String] {
        var tokens: [String] = []
        
        do {
            let snapshot = try await db.collection("FcmTokens")
                .whereField("roomIds", arrayContains: roomId)
                .getDocuments()
            
            snapshot.documents.forEach { document in
                let data = document.data()
                let token = data["token"] as! String
                tokens.append(token)
            }
            
            return tokens
        } catch {
            print("DEBUG: Fail to getParticipantsTokens with error \(error.localizedDescription)")
            return []
        }
    }
    
    func sendPush(_ pushMessage: PushMessage) async {
        guard let url = URL(string: "\(Constant.baseURL)/push") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-type")
        
        do {
            request.httpBody = try JSONEncoder().encode(pushMessage)
        } catch {
            print("DEBUG: Unable to convert PushMessage to JSON")
        }
        
        do {
            _ = try await URLSession.shared.data(for: request)
        } catch {
            print("DEBUG: Fail to sendPush with error \(error.localizedDescription)")
        }
    }
    
    func fetchMessages(
        roomId: String
    ) async -> [WrappedMessage] {
        if endPaging { return [] }
        guard let uid = auth.currentUser?.uid else { return [] }
        
        let commonQuery = db.collection("Rooms")
            .document(roomId)
            .collection("ChatLogs")
            .order(by: "timestamp") // timestamp 필드를 기준으로 오름차순 정렬
            .limit(toLast: limit) // 마지막에서 20개
        
        let requestQuery: Query
        
        /// 이전 페이지의 첫번재 Document가 있는지 확인
        if let startDoc = startDoc {
            /// 다음 페이지 = 이전 페이지의 첫번째 Document 이전까지의 20개
            requestQuery = commonQuery
                .end(beforeDocument: startDoc)
        } else {
            requestQuery = commonQuery
        }
        
        do {
            let snapshot = try await requestQuery.getDocuments()
            
            /// document가 비어있다면, 더 이상 다음 페이지는 존재하지 않음.
            /// 이후 쿼리 요청을 막기 위해서 Bool 타입 flag 변수 사용
            if snapshot.documents.isEmpty {
                endPaging = true
                return []
            }
            
            /// 현재 페이지의 첫번째 Document와 마지막 Document를 기록
            /// startDoc은 다음 페이지의 마지막 Document를 지정하기 위해서 사용
            /// lastDoc은 새로운 메세지를 구독하는 시작 Document를 지정하기 위해서 사용
            startDoc = snapshot.documents.first
            lastDoc = snapshot.documents.last
            
            
            let wrappedMessages = try snapshot.documents.map { document -> WrappedMessage in
                let message = try document.data(as: Message.self)
                if message.isSystemMsg {
                    return .system(message: message)
                } else if message.sender.uid == uid {
                    return .currentUser(message: message)
                } else {
                    return .otherUser(message: message)
                }
            }
            
            /// 만약 20개(페이지 Document 수) 보다 작다면, 마지막 페이지임
            if wrappedMessages.count < limit { endPaging = true }
            
            return wrappedMessages
        } catch {
            print("DEBUG: Fail to subscribeNewMessages with error: \(error.localizedDescription)")
            return []
        }
    }
    
    func subscribeNewMessages(
        roomId: String,
        completion: @escaping([WrappedMessage]) -> Void
    ) {
        guard let uid = auth.currentUser?.uid else { return }
        
        let commonQuery = db.collection("Rooms")
            .document(roomId)
            .collection("ChatLogs")
            .order(by: "timestamp") // timestamp를 기준으로 오름차순 정렬
        
        let requestQuery: Query
        
        /// 첫번째 페이지의 마지막 Document(구독의 시작 지점)를 가져옴
        if let lastDoc = lastDoc {
            /// lastDoc 이후의  Query
            requestQuery = commonQuery
                .start(afterDocument: lastDoc)
        } else {
            requestQuery = commonQuery
        }
        
        messageListenerRegistration = requestQuery.addSnapshotListener { snapshot, error in
            guard let document = snapshot?.documents else {
                print("DEBUG: Fail to subscribeNewMessages with error document is nil")
                return
            }
            
            do {
                let wrappedMessages = try document
                    .map { document -> WrappedMessage in
                        let message = try document.data(as: Message.self)
                        if message.isSystemMsg {
                            return .system(message: message)
                        } else if message.sender.uid == uid {
                            return .currentUser(message: message)
                        } else {
                            return .otherUser(message: message)
                        }
                    }
                
                DispatchQueue.main.async {
                    completion(wrappedMessages)
                }
                print("DEBUG: new message!")
            } catch {
                print("DEBUG: Fail to subscribeNewMessages with error: \(error.localizedDescription)")
            }
        }
    }
    
    func resetPageProperties() {
        endPaging = false
        startDoc = nil
        lastDoc = nil
    }
    
    func removeMessageListener() {
        messageListenerRegistration?.remove()
    }
    
    func removeCarPoolListener() {
        carPoolListenerRegistration?.remove()
    }
    
    func removeUserCarPoolListener() {
        userCarPoolListenerRegistration?.remove()
    }
}
