//
//  AllQuestionViewController.swift
//  ticketPRO RIPA
//
//  Created by Nitin on 5/5/21.
//

import UIKit

protocol PendingQuestionDelegate: class {
    func gotoselectedQuestion(index:Int,personArray:[[String: Any]])
}


class PendingQuestionsPopup: UIViewController,UITableViewDelegate,UITableViewDataSource {
   
    
    static func instantiateQuestion() -> PendingQuestionsPopup? {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "\(PendingQuestionsPopup.self)") as? PendingQuestionsPopup
    }
    
    
    weak var pendingQuestionDelegate : PendingQuestionDelegate?
    var previewViewModel = PreviewViewModel()
    var questionsArray : [QuestionResult1]?
    var optionsArray : [Questionoptions1]?
    var newquestionArry:Array<Any>?
    var newquestionIDArray:Array<Any>?
    var  personArray: [[String: Any]] = []
    var personIndex:Int?
    var newdic:Dictionary<Int, String>?
    
    
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var allQuestionTableView: UITableView!
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if AppConstants.theme == "1"{
            overrideUserInterfaceStyle = .dark
            }
        else{
           overrideUserInterfaceStyle = .light
            AppConstants.theme = "0"
        }
     }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        allQuestionTableView.delegate = self

        allQuestionTableView.dataSource = self
        allQuestionTableView.register(UINib(nibName: "NoQuestionTableViewCell", bundle: nil), forCellReuseIdentifier: "NoQuestionCell")
      
      print(newquestionArry!)
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NSNotification.Name(rawValue: "newDataNotif"), object: nil)

     
    }
    
    @IBAction func closeAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
    }
 
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(newquestionArry!)
         return newquestionArry!.count
     }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print(newquestionArry!)
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoQuestionCell", for: indexPath as IndexPath) as! NoQuestionTableViewCell
        print(indexPath.row)
        cell.question_lbl.text = (newquestionArry![indexPath.row] as? String)! + "*"
       // cell.question_lbl.text = ((newquestionArry![0] as AnyObject).question! as? String)!
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         dismiss(animated: true, completion: nil)
         personIndex = newquestionIDArray![indexPath.row] as? Int
        print(personIndex as Any)
        self.pendingQuestionDelegate?.gotoselectedQuestion(index: personIndex!, personArray:personArray)
       
     }
    
    
    @objc func refresh() {

       self.allQuestionTableView.reloadData() // a refresh the tableView.

   }
 

}
