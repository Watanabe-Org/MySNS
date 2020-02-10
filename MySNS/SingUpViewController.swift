//
//  SingUpViewController.swift
//  MySNS
//
//  Created by 渡邊輝夢 on 2020/02/09.
//  Copyright © 2020 Terumu Watanabe. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

class SingUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        emailTextField.delegate = self
        passTextField.delegate = self
        
        nameTextField.placeholder = "Plese enter your name"
        emailTextField.placeholder = "Please enter your e-mailaddress"
        passTextField.placeholder = "please enter password"
        
        nameTextField.clearButtonMode = UITextField.ViewMode.whileEditing
        emailTextField.clearButtonMode = UITextField.ViewMode.whileEditing
        passTextField.clearButtonMode = UITextField.ViewMode.whileEditing
        

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        
        if nameTextField.text == "" || emailTextField.text == "" || passTextField.text == "" {
            displayMessage(title: "Alert", message: "すべてのフォームに入力してください")
            return
        }
        
        guard let userName = nameTextField.text, let userEmail = emailTextField.text, let userPassword = passTextField.text else {return}
        post(name: userName, email: userEmail, pass: userPassword)
        
    }
    
    func post(name: String, email: String, pass: String) {
        
        var userData: [String: Any]?
        let dispatchGroup = DispatchGroup()
        
        guard let url = URL(string: "https://wata-sns.herokuapp.com/users") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = "name=\(name)&email=\(email)&password_digest=\(pass)".data(using: .utf8)
        
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
