//
//  EditCourseController.swift
//  Proyecto-App
//
//  Created by Anthony Leandro on 5/14/19.
//  Copyright © 2019 Anthony Leandro. All rights reserved.
//

import UIKit

protocol editCourse{
    func editCourse(for course_id: String, withName name: String, atIndex index: Int)
}

class EditCourseController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var courseNameOutlet: UITextField!
    var delegate: editCourse?
    var course: Course?
    var index: Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        courseNameOutlet.delegate = self
        courseNameOutlet.text = "\(course?.name ?? "Error at sending data")"
    }
    
    @IBAction func editAction(_ sender: Any) {
        if courseNameOutlet.text != "" {
            delegate?.editCourse(for: (course?._id)!, withName: courseNameOutlet.text!, atIndex: self.index!)
            navigationController?.popViewController(animated: true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

}
