//
//  ViewController.swift
//  MySNS
//
//  Created by 渡邊輝夢 on 2020/02/08.
//  Copyright © 2020 Terumu Watanabe. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class User {
    var name: String
    var email: String
    var created_at: String
    var updated_at: String
    var password_digest: String
    
    init(name: String,
         email: String,
         created_at: String,
         updated_at: String,
         password_digest: String ) {
        self.name = name
        self.email = email
        self.created_at = created_at
        self.updated_at = updated_at
        self.password_digest = password_digest
    }
}

class ViewController: UIViewController {
    
    var users: [User] = []
    var activityIndicater: UIActivityIndicatorView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        activityIndicater = UIActivityIndicatorView()
        activityIndicater.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicater.center = self.view.center
        activityIndicater.startAnimating()
        
        getData()
    }
    
    func getData() {
        let dispatchGroup = DispatchGroup()
        let jsonString = "https://wata-sns.herokuapp.com/users"
        guard let url = URL(string: jsonString) else { return }
        
        
        dispatchGroup.enter()
        let task: URLSessionTask = URLSession.shared.dataTask(with: url) {data, response, error in
                                                                guard let data = data else { return }

                                                                    do {
                                                                        let json = try? JSON(data: data)
                                                                        
                                                                        for i in 0...( json!.count - 1 ) {
                                                                            
                                                                            let user = User(name: json![i]["name"].stringValue,
                                                                                            email: json![i]["email"].stringValue,
                                                                                            created_at: json![i]["created_at"].stringValue,
                                                                                            updated_at: json![i]["updated_at"].stringValue,
                                                                                            password_digest: json![i]["password_digest"].stringValue)
                                                                            
                                                                            print(user.name)
                                                                            self.users.append(user)
                                                                        }
                                                                        dispatchGroup.leave()
                                                                    } catch {
                                                                        print(error)
                                                                    }
        }
        task.resume()
        
        dispatchGroup.notify(queue: .main) {
            print("読み込み完了")
            self.performSegue(withIdentifier: "toLogin", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toLogin" {
            let loginVC = segue.destination as! LoginViewController
            loginVC.users = self.users
        }
    }
    

}

