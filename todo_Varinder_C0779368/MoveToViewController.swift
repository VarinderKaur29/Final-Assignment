//
//  MoveToViewController.swift
//  todo_Varinder_C0779368
//
//  Created by Varinder Chahal on 2020-06-25.
//  Copyright © 2020 Varinder Chahal. All rights reserved.
//

import UIKit
import CoreData

class MoveToViewController: UIViewController {
    // create a context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    var folder = [Archived]()
    var selectedtask: [TaskData]?{
        didSet{
            loadFolders()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func loadFolders() {
           let request: NSFetchRequest<Archived> = Archived.fetchRequest()
           
           // predicate if you want
        let folderPredicate = NSPredicate(format: "NOT name MATCHES %@", selectedtask?[0].archivedFolder?.name ?? "")
           request.predicate = folderPredicate
           
           do {
               folder = try context.fetch(request)
               print(folder.count)
           } catch {
               print("Error fetching data \(error.localizedDescription)")
           }
       }
}


extension MoveToViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folder.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "")
        cell.textLabel?.text = folder[indexPath.row].name
        cell.backgroundColor = .darkGray
        cell.textLabel?.textColor = .lightGray
        cell.tintColor = .lightText
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Move to \(folder[indexPath.row].name!)", message: "Are you sure?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Move", style: .default) { (action) in
            for note in self.selectedtask! {
                note.archivedFolder = self.folder[indexPath.row]
            }
           // self.performSegue(withIdentifier: "dismissMoveToVC", sender: self)
        }
        
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        noAction.setValue(UIColor.orange, forKey: "titleTextColor")
        alert.addAction(yesAction)
        alert.addAction(noAction)
        present(alert, animated: true, completion: nil)
    }
}
