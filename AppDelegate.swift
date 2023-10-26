//
//  AppDelegate.swift
//  WebServiceDemo
//
//  Created by Krunal on 27/10/23.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let dbData = RealmManager.shared.fetchObjects(with: Model_EmployeeRealm.self)
        print("***************+++++++++++++ \(dbData.count) ++++++++++++++++***********")
        if dbData.count > 0{
//            let predicate = NSPredicate(format: "id == %@",NSNumber(value: false))
            let predicate = NSPredicate(format: "employeeName == %@","Tiger Nixon")
            let searchData = RealmManager.shared.fetchObjects(Model_EmployeeRealm.self, predicate: predicate)
            print(searchData)
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

