//
//  AddEditTaskViewController.swift
//  todo_Varinder_C0779368
//
//  Created by Varinder Chahal on 2020-06-25.
//  Copyright © 2020 Varinder Chahal. All rights reserved.
//

import UIKit
import CoreData
class AddEditTaskViewController: UIViewController {
    
    var editTaskData = TaskData()
    var isEdit = false
   var taskdata = TaskData()
    @IBOutlet weak var taskNameTxtField: UITextField!
    @IBOutlet weak var dayRequired: UITextField!
    @IBOutlet weak var completedDays: UITextField!
    @IBAction func saveData(_ sender: Any) {
        let daysR = Int(dayRequired.text!) ?? 0
        let daysC = Int(completedDays.text!) ?? 0
        if daysC > daysR{
            errorAlert()
        }else{
            saveDataToCoreData(taskName: taskNameTxtField.text!, totalDays: daysR, daysCompleted: daysC)
            navigationController?.popViewController(animated: true)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
           //creating context from the container
        _ = appDelegate.persistentContainer.viewContext
        if isEdit == true{
            
            taskNameTxtField.text =  "\(editTaskData.taskName ?? "")"
            dayRequired.text = "\(editTaskData.dayRequired)"
            completedDays.text = "\(editTaskData.dayCompleted)"
        }
        
    }
  
    func errorAlert() {
        let alert = UIAlertController(title: "", message: "Required day should be greater", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
            let daysneed = Int(self.dayRequired.text!) ?? 0
            let daysover = Int(self.completedDays.text!) ?? 0
            if daysover > daysneed{
                self.errorAlert()
            }
        }))
        let temp = 0
        completedDays.text = String(temp)
        self.present(alert, animated: true)
    }
    
    func saveDataToCoreData(taskName : String,totalDays : Int,daysCompleted : Int){
        
        if isEdit == true{
            
            editTaskData.taskName = taskNameTxtField.text
            editTaskData.dayRequired = Int64(dayRequired.text!)!
            editTaskData.dayCompleted = Int64(completedDays.text!)!
            
        }else{
            taskdata = TaskData(context: managedContext)
            taskdata.taskName = taskName
            taskdata.dayRequired = Int64(totalDays)
            taskdata.dayCompleted = Int64(daysCompleted)
            let Currentdate = Date()
            let df = DateFormatter()
            df.dateFormat = "dd/MM/yyyy"
            taskdata.currentdate = Currentdate
        }
        do{
            try managedContext.save()
        }catch let error as NSError{
            print("Error Could not save Data. \(error),\(error.userInfo)")
        }
        
    }
    
}
