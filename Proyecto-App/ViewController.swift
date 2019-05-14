//
//  ViewController.swift
//  Proyecto-App
//
//  Created by Anthony Leandro on 5/8/19.
//  Copyright © 2019 Anthony Leandro. All rights reserved.
//

import UIKit

class Course{
    var name = ""
    var _id = ""
    convenience init(name: String, _id: String){
        self.init()
        self.name = name
        self._id = _id
    }
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, addCourse, editCourse {
    
    var courses: [Course] = []
    var editingIndex: Int? = nil
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ------ I'm honestly NOT proud of what I did on this method ------
        guard let url = URL(string: "https://proyecto-api.herokuapp.com/courses") else { return }
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    
                    DispatchQueue.main.async {
                        for object in (json as! NSArray as! [NSDictionary]){
                            let name = object["name"] as! String
                            let _id = object["_id"] as! String
                            self.courses.append(Course(name: name, _id: _id))
                        }
                        self.tableView.reloadData()
                    }

                }catch{
                    print(error)
                }
            }
        }.resume()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "courseCell", for: indexPath) as! CourseCell
        
        cell.courseNameLabel.text = courses[indexPath.row].name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let edit = editAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [edit])
    }
    
    func editAction(at indexPath: IndexPath) -> UIContextualAction{
        
        self.editingIndex = indexPath.row // IMPORTANT awful patch for knowing which index of table I'm using for editing
        
        let action = UIContextualAction(style: .normal, title: "Edit"){ (action, view, completion) in
            self.performSegue(withIdentifier: "showEditView", sender: self)
            completion(true)
        }
        
        action.image = UIImage(named: "Edit")
        action.backgroundColor = UIColor(red: 0.0275, green: 0.4353, blue: 0.6, alpha: 1.0) /* #076f99 */
        
        return action
    }
    
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction{
        
        let action = UIContextualAction(style: .normal, title: "Delete"){ (action, view, completion) in
            self.deleteCourse(courseIndex: indexPath.row)
            completion(true)
        }
        
        action.image = UIImage(named: "Trash")
        action.backgroundColor = UIColor(red: 0.6, green: 0.0863, blue: 0.0863, alpha: 1.0) /* #991616 */
        
        return action
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is AddCourseController {
            let vc = segue.destination as! AddCourseController
            vc.delegate = self
        }
        else{
            if segue.destination is EditCourseController {
                if let vc = segue.destination as? EditCourseController{
                    vc.course = courses[self.editingIndex!]
                    vc.index = self.editingIndex
                    vc.delegate = self
                }
            }
        }
    }
    
    func addCourse(name: String) {
        let parameters = ["name": name] as [String: Any]
        let stringUrl = "https://proyecto-api.herokuapp.com/courses"
        let method = "POST"
        
        callAPI(withParameters: parameters, withStringURL: stringUrl, withMethod: method)
    }
    
    func editCourse(for course_id: String, withName name: String, atIndex index: Int) {
        let parameters = ["name": name, "index": index] as [String: Any]
        let stringUrl = "https://proyecto-api.herokuapp.com/courses/" + course_id
        let method = "PUT"
        
        callAPI(withParameters: parameters, withStringURL: stringUrl, withMethod: method)
    }
    
    func deleteCourse(courseIndex: Int){
        let course_id = self.courses[courseIndex]._id
        let parameters = ["index": courseIndex] as [String: Any]
        let stringUrl = "https://proyecto-api.herokuapp.com/courses/" + course_id
        let method = "DELETE"
    
        callAPI(withParameters: parameters, withStringURL: stringUrl, withMethod: method)
    }
    
    
    func callAPI(withParameters parameters: [String: Any], withStringURL stringUrl: String, withMethod method: String){
        
        guard let url = URL(string: stringUrl) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = method
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody = httpBody
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    guard let jsonObject = json as? [String: Any] else { return }
                    
                    DispatchQueue.main.async {
                        // Not including GET because I'm loading data in the viewDidLoad() function using another way
                        if method == "POST"{
                            guard let name = jsonObject["name"] as? String else { return }
                            guard let _id = jsonObject["_id"] as? String else { return }
                            self.courses.append(Course(name: name, _id: _id))
                        }
                        if method == "PUT"{
                            guard let index = parameters["index"] as? Int else { return }
                            guard let name = jsonObject["name"] as? String else { return }
                            self.courses[index].name = name
                        }
                        if method == "DELETE"{
                            guard let index = parameters["index"] as? Int else { return }
                            self.courses.remove(at: index)
                        }
                        // Finally
                        self.tableView.reloadData()
                    }
                }catch{
                    print(error)
                }
            }
            }.resume()
    }
}
