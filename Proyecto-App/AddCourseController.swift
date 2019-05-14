//
//  AddCourseController.swift
//  Proyecto-App
//
//  Created by Anthony Leandro on 5/8/19.
//  Copyright © 2019 Anthony Leandro. All rights reserved.
//

import UIKit

protocol addCourse{
    func addCourse(name: String)
}

class AddCourseController: UIViewController, UITextFieldDelegate {
    
    var delegate: addCourse?
    override func viewDidLoad() {
        super.viewDidLoad()
        courseNameOutlet.delegate = self
    }
    
    @IBOutlet weak var courseNameOutlet: UITextField!
    @IBAction func addAction(_ sender: Any) {
        if courseNameOutlet.text != "" {
            delegate?.addCourse(name: courseNameOutlet.text!)
            navigationController?.popViewController(animated: true)
            
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    
    
}
