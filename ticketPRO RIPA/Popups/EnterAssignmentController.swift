//
//  EnterAssignmentController.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 30/11/21.
//

import UIKit

protocol assignmntDelegate: AnyObject {
    func sendAssignment(assignmentTxt : String)
    func removeView()
}

class EnterAssignmentController: UIViewController,UITextFieldDelegate {

    var  delegate : assignmntDelegate?
    @IBOutlet weak var assinText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.assinText?.setLeftPaddingPoints(10)
        self.assinText?.setRightPaddingPoints(10)
        // Do any additional setup after loading the view.
    }
 
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        assinText.becomeFirstResponder()
    }
    
  @IBAction func action_cancelAssignment(_ sender: Any) {
      self.delegate?.removeView()
      self.dismiss(animated: true, completion: nil)
  }
    
    @IBAction func action_submtAssignment(_ sender: Any) {
        if self.assinText.text == "" {
            self.showAlertMessage(titleStr: "", messageStr: "Please enter assignment type")
        }
        else {
          self.delegate?.sendAssignment(assignmentTxt: assinText.text!)
          self.dismiss(animated: true, completion: nil)
        }
    }

}
