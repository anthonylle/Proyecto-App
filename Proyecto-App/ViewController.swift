//
//  ViewController.swift
//  Proyecto-App
//
//  Created by Anthony Leandro on 5/8/19.
//  Copyright © 2019 Anthony Leandro. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, addCourse {
    
    var courses: [Course] = []
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // ------ I'm honestly NOT proud of this ------
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            deleteCourse(courseIndex: indexPath.row)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! AddCourseController
        vc.delegate = self
    }
    
    func addCourse(name: String) {
        let parameters = ["name": name] as [String: Any]
        let stringUrl = "https://proyecto-api.herokuapp.com/courses"
        let method = "POST"
        
        callAPI(withParameters: parameters, withStringURL: stringUrl, withMethod: method)
    }
    
    func deleteCourse(courseIndex: Int){
        let course_id = self.courses[courseIndex]._id
        let parameters = ["index": courseIndex] as [String: Any]
        let stringUrl = "https://proyecto-api.herokuapp.com/courses/" + course_id
        print("String URL for DELETE: \(stringUrl)")
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




class Course{
    var name = ""
    var _id = ""
    convenience init(name: String, _id: String){
        self.init()
        self.name = name
        self._id = _id
    }
}

