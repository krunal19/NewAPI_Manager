//
//  ViewController.swift
//  WebServiceDemo
//
//  Created by Krunal on 27/10/23.
//

import UIKit
import Foundation
import RealmSwift

struct Model_Employee : Codable {
    let data : [Employee]?
    let message : String?
    let status : String?
}

struct Employee : Codable {
    
    let employeeAge : Int?
    let employeeName : String?
    let employeeSalary : Int?
    let id : Int?
    let profileImage : String?
}
struct Model_Employee_Create : Codable {
    let data : Create_Data?
    let message : String?
    let status : String?
}
struct Create_Data : Codable {

    let age : String?
    let id : Int?
    let name : String?
    let salary : String?
}
class Model_EmployeeRealm: Object,Codable {
    
    @Persisted var employeeAge: Int?
    @Persisted var employeeName: String?
    @Persisted var employeeSalary: Int?
    @Persisted(primaryKey: true) var id: Int?
    @Persisted var profileImage: String?
}
class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        getRequest()
//        postRequest()
        realmGetRequest()
        
    }
    
    @IBAction func TappedOnNext(_ sender: Any) {
        let SB_Main = UIStoryboard(name: "Main", bundle: Bundle.main)
        let vc = SB_Main.instantiateViewController(withIdentifier: "NextVC") as! NextVC
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func getRequest(){
        //        var parameter = [String:Any]()
        //        parameter["logUsername"] = self.txtEmail.text//"krunal.prajapati@digiboxx.com"
        //        parameter["logUserpass"] = self.txtPassword.text//"Krunal@123"
        
        WebService.call.withPath("https://dummy.restapiexample.com/api/v1/employees",parameter: [:], isWithLoading: false, methods: .get, isQueryString: false){ (responseDic) in
            print(responseDic)
            WebService.objectFrom(dic: responseDic) { (APIResponse: Model_Employee?) in
                if APIResponse?.status == "success"{
                    print(APIResponse?.data?.first?.employeeName ?? "")
                }
            }
        }
    }
    func postRequest(){
        var parameter = [String:Any]()
        parameter["name"] = "Krunal1"
        parameter["salary"] = "100000"
        parameter["age"] = "26"
        
        WebService.call.withPath("https://dummy.restapiexample.com/api/v1/create",parameter: [:], isWithLoading: false, methods: .post){ (responseDic) in
            print(responseDic)
            WebService.objectFrom(dic: responseDic) { (APIResponse: Model_Employee_Create?) in
                if APIResponse?.status == "success"{
                    print(APIResponse?.data?.id ?? "")
                }
            }
        }
    }
    func realmGetRequest(){
        WebService.call.withPath("https://dummy.restapiexample.com/api/v1/employees",parameter: [:], isWithLoading: false, methods: .get, isQueryString: false){ (responseDic) in
            print(responseDic)
            WebService.objectFrom(dic: responseDic) { (APIResponse: Model_APIResponse<[Model_EmployeeRealm]>?) in
                if APIResponse?.status == "success"{
                    print(APIResponse?.data?.first?.employeeName ?? "")
                    if let empData = APIResponse?.data{
                        RealmManager.shared.adds(empData)
                    }
                }
            }
        }
    }
}


//func GetCurrencyList(completion: @escaping ([CurrencyList]?, Error?) -> Void){
//    let parameters: [String: Any] = ["app_id": "4b0dbdb032e544eda6e4d123b543f85f"]
//
//    AF.request(GetCurrencyUrl, method: .get, parameters: parameters).responseJSON { response in
//        switch response.result {
//        case .success:
//            do {
//                if let data = response.data {
//                    let decoder = JSONDecoder()
//                    let currencyDict = try decoder.decode([String: String].self, from: data)
//
//                    // Convert the dictionary to an array of CurrencyInfo objects.
//                    let currencyInfoArray = currencyDict.map { (code, name) in
//                        return CurrencyList(code: code, name: name)
//                    }
//                    completion(currencyInfoArray, nil)
//                } else {
//                    completion(nil, NSError(domain: "No data received", code: 0, userInfo: nil))
//                }
//            } catch {
//                completion(nil, error)
//            }
//        case .failure(let error):
//            completion(nil, error)
//        }
//    }
//}
