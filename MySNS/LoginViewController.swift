//
//  LoginViewController.swift
//  MySNS
//
//  Created by 渡邊輝夢 on 2020/02/08.
//  Copyright © 2020 Terumu Watanabe. All rights reserved.
//

import UIKit
import SwiftyJSON

class LoginViewController: UIViewController {
    
    var users: [User] = []
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        emailTextField.placeholder = "Please enter your e-mailadress"
        passTextField.placeholder = "please enter Passwored"
        
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        
        guard let email = emailTextField.text, let pass = passTextField.text else {return}
        post(email: email, pass: pass)
    }
    
   func post(email: String, pass: String) {
       
       var userData: [String: Any]?
       let dispatchGroup = DispatchGroup()
       
       guard let url = URL(string: "https://wata-sns.herokuapp.com/users") else { return }
       var request = URLRequest(url: url)
       request.httpMethod = "POST"
       request.httpBody = "email=\(email)&password_digest=\(pass)".data(using: .utf8)
       
       dispatchGroup.enter()
       let task: URLSessionTask = URLSession.shared.dataTask(with: request,
                                                             completionHandler: { (data, response, error) in
                                                               guard let data = data, let response = response  else { return }
                                                               do {
                                                                   guard let json = try? JSON(data: data) else {return}
                                                                   print(json)
                                                                   userData = json.dictionaryObject
                                                                   dispatchGroup.leave()
                                                               } catch {
                                                                   print(error)
                                                               }
       })
       task.resume()
       dispatchGroup.notify(queue: .main) {
           guard let userData = userData else {return}
               if userData.keys.contains("error") {
                   
                   let errorArray = userData["error"] as! [String]
                   var message: String = ""
                   for i in 0...errorArray.count - 1 {
                       message += errorArray[i]
                       message += "\n"
                   }
                   self.displayMessage(title: "Alert", message: message)
                   return
               }
           self.displayMessage(title: "Succeed!!", message: "")
       }
   }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toUserList" {
            let userListVC = segue.destination as! UserTableViewController
            userListVC.users = self.users
        }
    }
    
    func displayMessage(title: String,message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let action = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
