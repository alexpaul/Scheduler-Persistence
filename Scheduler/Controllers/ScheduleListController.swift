//
//  ViewController.swift
//  Scheduler
//
//  Created by Alex Paul on 11/20/19.
//  Copyright © 2019 Alex Paul. All rights reserved.
//

import UIKit

class ScheduleListController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  
  // data - an array of events
  var events = [Event]()
  
  var isEditingTableView = false {
    didSet { // property observer
      // toggle editing mode of table view
      tableView.isEditing = isEditingTableView
      
      // toggle bar button item's title between "Edit" and "Done"
      navigationItem.leftBarButtonItem?.title = isEditingTableView ? "Done" : "Edit"
    }
  }
  
  lazy var dateFormatter:  DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE, MMM d, yyyy, hh:mm a"
    formatter.timeZone = .current
    return formatter
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loadEvents()
    tableView.dataSource = self
    
    // print path to documents directory
    print(FileManager.getDocumentsDirectory())
  }
  
  private func loadEvents() {
    do {
      events = try PersistenceHelper.loadEvents()
    } catch {
      print("error loading events: \(error)")
    }
  }
  
  private func deleteEvent(indexPath: IndexPath) {
    do {
      try PersistenceHelper.delete(event: indexPath.row)
    } catch {
      print("error deleting event: \(error)")
    }
  }
  
  @IBAction func addNewEvent(segue: UIStoryboardSegue) {
    // caveman debugging
    
    // get a reference to the CreateEventController instance
    guard let createEventController = segue.source as? CreateEventController,
      let createdEvent = createEventController.event else {
        fatalError("failed to access CreateEventController")
    }
    
    // persist (save) event to documents directory
    do {
      try PersistenceHelper.create(event: createdEvent) // adds event at the of array
    } catch {
      print("error saving event with error: \(error)")
    }
    
    // insert new event into our events array
    events.append(createdEvent)
    
    // create an indexPath to be inserted into the table view
    let indexPath = IndexPath(row: events.count - 1, section: 0) // will represent top of table view
    
    // 2. we need to update the table view
    // use indexPath to insert into table view
    tableView.insertRows(at: [indexPath], with: .automatic)
  }
  
  @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
    isEditingTableView.toggle() // changes a boolean value
  }
}

extension ScheduleListController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return events.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
    let event = events[indexPath.row]
    cell.textLabel?.text = event.name
    cell.detailTextLabel?.text = dateFormatter.string(from: event.date)
    return cell
  }
  
  // MARK:- deleting rows in a table view
  func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    switch editingStyle {
    case .insert:
      // only gets called if "insertion control" exist and gets selected
      print("inserting....")
    case .delete:
      print("deleting..")
      // 1. remove item for the data model e.g events
      events.remove(at: indexPath.row) // remove event from events array
      
      deleteEvent(indexPath: indexPath)
      
      // 2. update the table view
      tableView.deleteRows(at: [indexPath], with: .automatic)
    default:
      print("......")
    }
  }
  
  // MARK:- reordering rows in a table view
  func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    let eventToMove = events[sourceIndexPath.row] // save the event being moved
    events.remove(at: sourceIndexPath.row)
    events.insert(eventToMove, at: destinationIndexPath.row)
    
    // re-save array in docuemnts directory
    PersistenceHelper.reorderEvents(events: events)
    do {
      events = try PersistenceHelper.loadEvents()
      tableView.reloadData()
    } catch {
      print("error loading events: \(error)")
    }
  }
}

