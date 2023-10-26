//
//  RealmManager.swift
//  WebServiceDemo
//
//  Created by Krunal on 06/03/23.

import Foundation
import RealmSwift

class RealmManager {
    
    static let shared = RealmManager()
    
    // NOTE:
    // Dont use generic realm instance to avoid Realm Excetion
    // let realm: Realm
    let realmBGThread = DispatchQueue(label: "realmDB", qos: .background)
    let realmThread = DispatchQueue(label: "realmDB")
    
    private init() {
        let fileManager = FileManager.default
        
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        //        print(documentsPath.appendingPathComponent("default.realm")
        
        if fileManager.fileExists(atPath: documentsPath.appendingPathComponent("default.realm").path){
            try? fileManager.removeItem(atPath: documentsPath.appendingPathComponent("default.realm").path)
        }
        if fileManager.fileExists(atPath: documentsPath.appendingPathComponent("default.realm.lock").path){
            try? fileManager.removeItem(atPath: documentsPath.appendingPathComponent("default.realm.lock").path)
        }
        if fileManager.fileExists(atPath: documentsPath.appendingPathComponent("default.realm.management").path){
            try? fileManager.removeItem(atPath: documentsPath.appendingPathComponent("default.realm.management").path)
        }
        if fileManager.fileExists(atPath: documentsPath.appendingPathComponent("default.realm.note").path){
            try? fileManager.removeItem(atPath: documentsPath.appendingPathComponent("default.realm.note").path)
        }
        
        var config = Realm.Configuration()
        
        let urls = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        
        if let applicationSupportURL = urls.last {
            do {
                try fileManager.createDirectory(at: applicationSupportURL, withIntermediateDirectories: true, attributes: nil)
                config.fileURL = applicationSupportURL.appendingPathComponent("DemoRealm.realm")
            } catch let err {
                print(err)
                
            }
        }
        
        // Set this as the configuration used for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        print (Realm.Configuration.defaultConfiguration.fileURL!)
        
        // This'll print our realm db path
        print("#Realm Path:\(String(describing: Realm.Configuration.defaultConfiguration.fileURL))")
        
        
    }
    
    
    // MARK: - Public Methods
    
    func add<T: Object>(_ object: T) {
        if let realmAdd = try? Realm() {
            do {
                try realmAdd.write {
                    realmAdd.add(object, update: .modified)
                }
            } catch let error {
                print("#Failed to add object to Realm with error: \(error.localizedDescription)")
                post(error)
            }
        }
    }
    func adds<T: Object>(_ object: [T]) {
        if let realmAdd = try? Realm() {
            do {
                try realmAdd.write {
                    realmAdd.add(object, update: .modified)
                }
            } catch let error {
                print("#Failed to add object to Realm with error: \(error.localizedDescription)")
                post(error)
            }
        }
    }
    func updateObject<T: Object>(_ object: T?) -> Bool {
        guard let realmUpdate = try? Realm() else {return false}
        guard let object: T = object else { return false }
        guard !object.isInvalidated else { return false }
        
        do {
            try realmUpdate.write {
                realmUpdate.add(object, update: .all)
            }
            return true
        } catch let error {
            print("Writing failed for ", String(describing: T.self), " with error ", error)
        }
        return false
    }
    func update<T: Object>(_ object: T, with dictionary: [String: Any?]) {
        guard let realm = try? Realm() else {return}
        do {
            try realm.write {
                for (key, value) in dictionary {
                    if let value = value {
                        object.setValue(value, forKey: key)
                    }
                }
            }
        } catch let error {
            print("#Failed to update object in Realm with error: \(error.localizedDescription)")
            post(error)
        }
    }
    
    func delete<T: Object>(_ object: T) {
        guard let realmDelete = try? Realm() else {return}
        
        do {
            try realmDelete.write {
                realmDelete.delete(object)
            }
        } catch let error {
            print("#Failed to delete object from Realm with error: \(error.localizedDescription)")
            post(error)
        }
    }
    func delete<T: Object>(ofType type: T.Type, withId id: Int) {
        guard let realm = try? Realm() else { return }
        let objectsToDelete = realm.objects(type).filter("id == %@", id)
        do {
            try realm.write {
                realm.delete(objectsToDelete)
            }
        } catch let error {
            print("#Failed to delete objects from Realm with error: \(error.localizedDescription)")
            post(error)
        }
    }
    func deleteObjects<T: Object>(_ object: T.Type, where predicate: NSPredicate) {
        guard let realm = try? Realm() else { return }
        let objectsToDelete = realm.objects(object).filter(predicate)
        do {
            try realm.write {
                realm.delete(objectsToDelete)
            }
        } catch let error {
            print("Failed to delete objects from Realm with error: \(error.localizedDescription)")
        }
    }
    func deleteObjects<T: Object>(_ object: [T]) {
        guard let realmDeletes = try? Realm() else {return}
        do {
            try realmDeletes.write {
                realmDeletes.delete(object)
            }
        } catch let error {
            print("#Failed to delete object from Realm with error: \(error.localizedDescription)")
            post(error)
        }
    }
    func removeObjects<T>(_ objects: [T]) where T: Object {
        if let realmRemove = try? Realm() {
            try? realmRemove.write {
                realmRemove.delete(objects)
            }
        }
    }
    
    func fetchObjects<T: Object>(with type: T.Type)-> [T] where T: Object {
        guard let realmFetch = try? Realm() else { return [] }
        return Array(realmFetch.objects(T.self))
    }
    func fetchObjects<T: Object>(with type: T.Type, completion: @escaping ([T]) -> Void) where T: Object {
        //        DispatchQueue(label: "realm-fetch").async {
        guard let realm = try? Realm() else {
            completion([])
            return
        }
        let objects = Array(realm.objects(T.self))
        completion(objects)
        //        }
    }
    
    func fetchObjects<T>(_ type: T.Type, predicate: NSPredicate) -> [T]? where T: Object {
        guard let realmFetch2 = try? Realm() else { return nil }
        return Array(realmFetch2.objects(type).filter(predicate))
    }
    
    func fetchObjects<T>(_ type: T.Type, predicates: NSCompoundPredicate,key: String, key2:String , ascending: Bool = false) -> [T]? where T: Object {
        guard let realmFetch2 = try? Realm() else { return nil }
        var arr = Array(realmFetch2.objects(type).filter(predicates).sorted(byKeyPath: key, ascending: ascending).sorted(byKeyPath: key2, ascending: ascending))
        //        if type == RealmModel_Home.self{
        //            if let index = arr.firstIndex(where: { ($0 as? RealmModel_Home)?.folderName == "DigiFotos" }) {
        //                // Remove the object with name "DigiFotos" from the array and store it in a separate variable
        //                let digiFotosObject = arr.remove(at: index)
        //                // Insert the "DigiFotos" object at the beginning of the array
        //                arr.insert(digiFotosObject, at: 0)
        //            }
        //        }
        return arr
    }
    
    func fetchPhotoByName<T>(_ type: T.Type, name: String) -> T? where T: Object {
        guard let realmF = try? Realm() else { return nil }
        let scope = realmF.objects(T.self).filter("title = %@", name)
        return scope.first
    }
    func fetchPhotoById<T>(_ type: T.Type, id: Int) -> T? where T: Object {
        guard let realmFid = try? Realm() else { return nil }
        let scope = realmFid.objects(T.self).filter("sFileId = %@", id)
        return scope.first
    }
    func fetchAlbumById<T>(_ type: T.Type, id: Int) -> [T]? where T: Object {
        guard let realm = try? Realm() else { return nil }
        let folders = realm.objects(T.self).filter("folderId = %@", id)
        return Array(folders)
    }
    func isAvailableInDB<T>(_ type: T.Type, filters : [String:Int]) -> [T]? where T: Object {
        guard let realmFetch2 = try? Realm() else { return nil }
        var predicates : [NSPredicate] = []
        for (key, value) in filters{
            print(key, value)
            predicates.append(NSPredicate(format: "\(key) == %@", NSNumber(value:value)))
        }
        return Array(realmFetch2.objects(type).filter(NSCompoundPredicate(type: .and, subpredicates: predicates)))
    }
    
    //    func storeAlbumFoto(obj:RealmDigiFoto, folderId:Int){
    //
    //        let obj = RealmAlbumFotos.init(title: obj.title ?? "", ext: obj.ext ?? "", localUrl: obj.localUrl ?? "", localThumbnail: obj.localThumbnail ?? "", createDate: obj.createDate ?? Date(), strModifiedDate: obj.strModifiedDate ?? "", modifiedDate: obj.modifiedDate ?? Date(), size: obj.size ?? "", isOnSrever: obj.isOnServer , sFileId: obj.sFileId , sFileUrl: obj.sFileUrl ?? "", isFavorite: obj.isFavorite , isRecycleBin: obj.isRecycleBin , folderName: obj.folderName ?? "", folderId: Int64(folderId), duration: obj.duration , isVideo: obj.isVideo )
    //        self.add(obj)
    //    }
    
    func realmClearDB() {
        if let realmClear = try? Realm() {
            try? realmClear.write {
                realmClear.deleteAll()
            }
        }
    }
    // Realm error handling
    func post(_ error: Error) {
        NotificationCenter.default.post(name: Notification.Name("RealmError"), object: error)
    }
    
    func observeRealmErrors(in vc: UIViewController, completion: @escaping(Error?) -> Void) {
        NotificationCenter.default.addObserver(forName: Notification.Name("RealmError"),
                                               object: nil,
                                               queue: nil) { (notification) in
            completion(notification.object as? Error)
        }
    }
    
    func stopObservingRealmErrors(in vc: UIViewController) {
        NotificationCenter.default.removeObserver(vc, name: Notification.Name("RealmError"), object: nil)
    }
}
