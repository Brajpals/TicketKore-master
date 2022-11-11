//
//  LoginPopupViewController.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 20/04/22.
//

import UIKit


protocol loginPopupDelegate: AnyObject {
    func sendLoginIdToServer(loginTxt : String)
    func removePopupView()
}


class LoginPopupViewController: UIViewController ,UITextFieldDelegate{

    var  delegate : loginPopupDelegate?
    @IBOutlet weak var loginIdText: UITextField!
    var idText : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.loginIdText?.setLeftPaddingPoints(10)
        self.loginIdText?.setRightPaddingPoints(10)
       
    }
   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loginIdText.becomeFirstResponder()
    }

    @IBAction func action_cancelAssignment(_ sender: Any) {
        self.delegate?.removePopupView()
        self.dismiss(animated: true, completion: nil)
    }
      
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 2
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
    
      @IBAction func action_submtAssignment(_ sender: Any) {
          if self.loginIdText.text == "" {
              self.showAlertMessage(titleStr: "", messageStr: "Please enter your Identification Number!")
          }
          else {
            self.delegate?.sendLoginIdToServer(loginTxt: loginIdText.text!)
            self.dismiss(animated: true, completion: nil)
          }
      }


}
