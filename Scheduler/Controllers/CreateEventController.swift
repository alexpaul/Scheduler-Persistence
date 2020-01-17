//
//  CreateEventController.swift
//  Scheduler
//
//  Created by Alex Paul on 11/20/19.
//  Copyright © 2019 Alex Paul. All rights reserved.
//

import UIKit

class CreateEventController: UIViewController {
  
  @IBOutlet weak var createEventTextField: UITextField!
  @IBOutlet weak var datePicker: UIDatePicker!
  
  var event: Event? // default value is nil
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // set the view controller as the delegate for the text field
    createEventTextField.delegate = self
        
    // instantiate a default value for event
    event = Event(date: Date(), name: "Swift Rocks Lab") // Date()
  }
  
  @IBAction func datePickerChanged(sender: UIDatePicker) {
    // update date of event
    event?.date = sender.date
  }
}

extension CreateEventController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
    // dismiss the keyboard
    textField.resignFirstResponder()
    
    // update name of event
    event?.name = textField.text ?? "no event name"
    
    return true
  }
}
