//
//  WebService.swift
//  WebServiceDemo
//
//  Created by Krunal on 21/08/22.
//

import Foundation
import Alamofire
import SVProgressHUD
import SystemConfiguration
import UIKit
//
//Swifty json ServiceResponse
typealias ServiceResponse = ([String:Any])->()
//
////Check internet connection
var isReachable: Bool {
    return NetworkReachabilityManager()!.isReachable
}

//MARK: - WebService Class
public class WebService {
    
    //Variable Declaration
    static var call: WebService = WebService()
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0"
    let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "0.0"
    
    //MARK: - WebService Call
    func withPath(_ url: String, parameter: [String:Any]? = nil,isHeaderEmpty: Bool = false, isHeaderText: Bool = false, isWithLoading: Bool = true, images: [ModelAPIImg] = [ModelAPIImg](), keyId: String = "", keyValue:[Int] = [], videoKey: [String] = ["video"], videoData: [Data] = [Data](), audioKey: [String] = ["audio"], audioData: [Data] = [Data](), fileDate: [Data] = [Data](), fileName : [String] = [], isNeedToken: Bool = true, methods: HTTPMethod = .post, allowTimeOut: Bool = true, isQueryString: Bool = true, isNeedToAddBaseURL: Bool = true, isMultiPart:Bool = false, completionHandler: @escaping ServiceResponse) {
        
        //var alamoFireManager : SessionManager?
        let alamoFireManager = Session.default
        
        if CheckConnection.isConnectedToNetwork() {
            if isWithLoading {
                DispatchQueue.main.async {
                    if images.count > 0 {
                        
                    } else {
                        SVProgressHUD.setForegroundColor(UIColor.blue)
                        SVProgressHUD.setBackgroundColor(.clear)
                        SVProgressHUD.show()
                    }
                }
            }
            var headers = HTTPHeaders()
            
            if isHeaderEmpty{
                headers = []
            } else {
                if isNeedToken {
                    if !isHeaderText{
                        headers = ["Content-Type": "application/json" ]
                    }else{
                        headers = ["Content-Type": "text/plain"]//,"authorization" : "Bearer " + WebURL.accessToken]
                    }
                }
            }
            let loadURL =  url
            
            if allowTimeOut == false {
                alamoFireManager.session.configuration.timeoutIntervalForRequest = 36000
                alamoFireManager.session.configuration.timeoutIntervalForResource = 36000
                
            } else {
                alamoFireManager.session.configuration.timeoutIntervalForRequest = 60
            }
            
            if images.count > 0 || videoData.count > 0 || audioData.count > 0 || isMultiPart {
                alamoFireManager.upload(multipartFormData: { multipartFormData in
                    if let my_param = parameter {
                        for (key, value) in my_param {
                            multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key)
                        }
                    }
                    for i in 0..<keyValue.count{
                        multipartFormData.append("\(i)".data(using: String.Encoding.utf8)!, withName: keyId)
                    }
                    for i in 0..<images.count {
                        multipartFormData.append(images[i].image.jpegData(compressionQuality: 0.75)!, withName: images[i].key, fileName: "image", mimeType: "image/jpeg")
                    }
                    for i in 0..<videoData.count {
                        multipartFormData.append(videoData[i], withName: videoKey[i], fileName: "file.mp4", mimeType: "video/mp4")
                    }
                    for i in 0..<audioData.count {
                        multipartFormData.append(audioData[i], withName: audioKey[i], fileName: "file.m4a", mimeType: "audio/m4a")
                    }
                    for i in 0..<fileDate.count{
                        multipartFormData.append(fileDate[i], withName: "chooseFile1", fileName: fileName[i])
                    }
                }, to: loadURL, method: methods, headers: headers).responseJSON { response in
                    if isWithLoading {
                        SVProgressHUD.dismiss()
                    }
                    debugPrint("//-------------------------------------------------------")
                    debugPrint("URL \(loadURL)")
                    debugPrint("Header: \(headers)")
                    debugPrint("Paramater \(parameter ?? [:])")
                    debugPrint("StatusCode : \(response.response?.statusCode ?? 0)")
                    if let responseData = response.data{
                        print("API Response\n\(String(data: responseData, encoding: String.Encoding.utf8) ?? "No response found")")
                    }
                    print("-------------------------------------------------------//")
                    self.handleResponse(statusCode: response.response?.statusCode, result: response.result, completionHandler: completionHandler)
                }
                
            } else {
                
                alamoFireManager.request(url, method: methods ,parameters: parameter, encoding: isQueryString ? JSONEncoding.default : URLEncoding.queryString ,headers: headers) .responseJSON  { response in
                    if isWithLoading {
                        SVProgressHUD.dismiss()
                    }
                    print("//-------------------------------------------------------")
                    debugPrint("URL \(loadURL)")
                    debugPrint("Header: \(headers)")
                    debugPrint("Paramater \(parameter ?? [:])")
                    debugPrint("StatusCode : \(response.response?.statusCode ?? 0)")
                    if let responseData = response.data{
                        print("API Response\n\(String(data: responseData, encoding: String.Encoding.utf8) ?? "No response found")")
                    }
                    print("-------------------------------------------------------//")
                    
                    self.handleResponse(statusCode: response.response?.statusCode, result: response.result, completionHandler: completionHandler)
                }
            }
            
        } else {
            if isWithLoading {
                SVProgressHUD.dismiss()
            }
            
            DispatchQueue.main.async {
                if var topController = UIApplication.shared.keyWindow?.rootViewController {
                    while let presentedViewController = topController.presentedViewController {
                        topController = presentedViewController
                    }
                    
                    if !topController.isKind(of: UIAlertController.self)  {
                        //Show Alert
                        showAlert(title: "Alert", message: "Please check your internet connection")
                        
                    }
                }
            }
        }
    }
    
    func handleResponse<T>(statusCode: Int?, result: Result<T,AFError>,completionHandler:@escaping ServiceResponse){
        print(statusCode ?? 0, "Status Code")
        switch result {
        case .success(let value):
            
            if let dicResult:[String:Any] = value as? [String:Any] {
                if let strMsg = dicResult["message"] as? String , let strStatus = dicResult["status"] as? String {
                    print(strMsg)
                }
            }
            completionHandler(value as? [String:Any] ?? [String:Any]())
            
        case .failure(let error):
            print(error)
            if let urlError = error as? URLError, urlError.code == .timedOut {
                // Handle timeout error
                debugPrint("timeout")
            } else {
                //showToast(text: error.localizedDescription)
                completionHandler([String:Any]())
            }
        }
    }
    
    static func objectFrom<D,Model:Decodable>(dic: D, completion: (Model?) -> Void) {
        //Where D is dictionary || array of dictionary
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: [])
            let objModel = try decoder.decode(Model.self, from: jsonData)
            completion(objModel)
            
        } catch let myJSONError {
            print(myJSONError)
            completion(nil)
        }
    }
    static func objectFromCodingKey<D,Model:Decodable>(dic: D, completion: (Model?) -> Void) {
        //Where D is dictionary || array of dictionary
        do {
            let decoder = JSONDecoder()
            //            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options: [])
            let objModel = try decoder.decode(Model.self, from: jsonData)
            completion(objModel)
            
        } catch let myJSONError {
            print(myJSONError)
            completion(nil)
        }
    }
}

struct Model_APIResponse<M:Codable>: Codable {
    let data : M?
    let message : String?
    let statusCode : Int?
    let status: String?
}

struct Model_Dummy: Codable{
    
}
//ModelAPIImg
class ModelAPIImg {
    
    var key = "images[]"
    var image = UIImage()
    
    init() {
        self.key = "images[]"
        self.image = UIImage()
    }
    
    init(image:UIImage) {
        self.key = "images[]"
        self.image = image
    }
    
    init(image:UIImage,key:String) {
        self.key = key
        self.image = image
    }
}

struct WebURL {
    static var baseURL = "https://apitest.digiboxx.com/"
    static var baseUrl2 = "https://test.digiboxx.com/"
    static var baseURLShare = "https://apptest.digiboxx.com/"
    static var accessToken = ""
}


//MARK: - CheckConnection Class
public class CheckConnection {
    
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
}
//MARK: - Show Alert
func showAlert(title:String = "Alert", message:String, txt_btn1:String = "Ok", txt_btn2:String = "", completion:((Int)->())? = nil){
    
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
    alert.addAction(UIAlertAction(title: txt_btn1, style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
        if completion != nil {
            completion!(0)
        }
    }))
    if txt_btn2.count > 0 {
        alert.addAction(UIAlertAction(title: txt_btn2, style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
            if completion != nil {
                completion!(1)
            }
        }))
    }
    if var topController = UIApplication.shared.windows.first?.rootViewController {
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        topController.present(alert, animated: true, completion: nil)
    }
}
