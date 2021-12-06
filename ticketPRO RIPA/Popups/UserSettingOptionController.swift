//
//  UserSettingOptionController.swift
//  ticketPRO RIPA
//
//  Created by Nitin Singh on 29/11/21.
//

import UIKit


protocol supervisorDelegate: AnyObject {
    func getUserSupervisor(sData:Supervisor?)
    func removeView()
}

class UserSettingOptionController: UIViewController {

     
    var supervisorArray = [Supervisor]()
   
    var  delegate : supervisorDelegate?
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "userCell", bundle: nil), forCellReuseIdentifier: "userCell")
    }
    
    
  @IBAction func removeOptionView(_ sender: Any) {
      self.dismiss(animated: true, completion: nil)
      self.delegate?.removeView()
  }
    
}

extension UserSettingOptionController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return supervisorArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        if let lName = supervisorArray[indexPath.row].LastName,let fName = supervisorArray[indexPath.row].FirstName {
            cell.textLabel?.text = lName + fName
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.getUserSupervisor(sData: supervisorArray[indexPath.row])
        self.dismiss(animated: true, completion: nil)
        self.delegate?.removeView()
    }
}
