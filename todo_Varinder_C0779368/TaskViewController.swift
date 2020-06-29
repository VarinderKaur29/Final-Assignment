//
//  ViewController.swift
//  todo_Varinder_C0779368
//
//  Created by Varinder Chahal on 2020-06-25.
//  Copyright © 2020 Varinder Chahal. All rights reserved.
//

import UIKit
import CoreData

class TaskViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    
    var taskData = [TaskData]()
    var filtertaskData = [TaskData]()
    var noteDate = Date()
    let managedContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBAction func sortTask(_ sender: Any) {
        if sortTask.title == "Sort By Name"{
            sortTask.title = "Sort By Date"
        }else{
            sortTask.title = "Sort By Name"
        }
    }
    @IBOutlet weak var sortTask: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.dataSource = self
        tableview.delegate = self
        searchBar.delegate = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadcoredata()
        tableview.reloadData()
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtertaskData.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TaskCell
        let data = filtertaskData[indexPath.row]
        //day to minus from current date
        let df = DateFormatter()
        df.dateFormat = "dd/MM/yyyy"
        let dayComp = DateComponents(day: Int(data.dayRequired))
        let currentdaytolastDate = Calendar.current.date(byAdding: dayComp, to: noteDate)
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.month, .day, .hour, .minute, .second]
        formatter.maximumUnitCount = 2
        
        
        cell.taskName.text = "Task Name: " + data.taskName!
        cell.addedDate.text =  "Added Date:" + df.string(from: noteDate)
        cell.totalDayRequired.text = "Total Days : \(String(data.dayRequired))"
        print(data.dayRequired)
        print(data.dayCompleted)
        
        // CHECK STATUS OF TASK
        
        let finalresult = data.dayRequired - data.dayCompleted
        if finalresult <= 0{
            cell.cellview.backgroundColor = .green
            cell.taskStatus.text = "Completed"
            cell.taskStatus.textColor = .red
        }else if finalresult == 1{
            cell.cellview.backgroundColor = .red
            cell.taskStatus.text = "Due"
            cell.taskStatus.textColor = .green
        }else{
            cell.taskStatus.text = "Status Unknown"
            cell.taskStatus.textColor = .none
        }
        
        cell.dayCompleted.text = "Last Day : \(df.string(from: currentdaytolastDate!))"
        
        //to get exact date
        let dayLeft = formatter.string(from: noteDate, to: currentdaytolastDate!)
        if let dayLeft1 = dayLeft{
            
            print(dayLeft1)
            if dayLeft1 == "0 day"{
                cell.backgroundColor = .red
                cell.taskStatus.text = "Overdue"
                cell.taskStatus.textColor = .green
                
            }else if dayLeft1 == "1 day" {
                cell.backgroundColor = .red
                cell.taskStatus.text = "Due"
                cell.taskStatus.textColor = .green
            }
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TaskCell
        
        let data = filtertaskData[indexPath.row]
        
        let finalresult = data.dayRequired - data.dayCompleted
        if finalresult <= 0{
            cell.cellview.backgroundColor = .green
            cell.taskStatus.text = "Completed"
            cell.taskStatus.textColor = .red
        }else{
            cell.cellview.backgroundColor = .red
            cell.taskStatus.text = "Overdue"
            cell.taskStatus.textColor = .green
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            managedContext.delete(self.filtertaskData[indexPath.row])
            filtertaskData.remove(at: indexPath.row)
            do{
                try managedContext.save()
                loadcoredata()
                self.tableview.reloadData()
            }
                
            catch{
                print("Failed")
            }
            
        }
    }
    
}
extension TaskViewController: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filtertaskData = searchText.isEmpty ? taskData : taskData.filter({ (item: TaskData) -> Bool in
            if (sortTask.title?.contains("Sort By Name"))! {
                return item.taskName!.range(of: searchText, options: .caseInsensitive) != nil
            }else{
                return item.currentdate?.description.range(of: searchText, options: .caseInsensitive) != nil
            }
            
        })
        tableview.reloadData()
    }
}

class TaskCell: UITableViewCell{
    @IBOutlet weak var taskName: UILabel!
    @IBOutlet weak var addedDate: UILabel!
    @IBOutlet weak var dayCompleted: UILabel!
    @IBOutlet weak var totalDayRequired: UILabel!
    @IBOutlet weak var taskStatus: UILabel!
    @IBOutlet weak var cellview: UIView!
    
}

extension TaskViewController{
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "edittask") {
            let destination = segue.destination as! AddEditTaskViewController
            destination.modalPresentationStyle = .fullScreen
            destination.isEdit = true
            if let indexpath = tableview.indexPathForSelectedRow{
                destination.editTaskData = filtertaskData[indexpath.row]
            }
        }
    }
    
    //Load core Data
    func loadcoredata(){
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
        
        let Context = appDelegate.persistentContainer.viewContext
        do{
            taskData = try Context.fetch(TaskData.fetchRequest() )
            filtertaskData = taskData
        }
        catch let error as NSError{
            print("Error Could not save Data. \(error),\(error.userInfo)")
        }
    }
}
