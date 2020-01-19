# Scheduler

Using FileManager and documents directory to save user created data. 


#### Screenshot of Main UI
![scheduler app](Assets/scheduler-app.png)


#### Getting the URL to the documents directory 
```swift 
FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
```

#### Appending a file name to the documents directory 
This file name will be used to save and retrive persisted data.
```swift 
getDocumentsDirectory().appendingPathComponent(filename)
```

#### Writing to the documents directory
```swift 
try data.write(to: url, options: .atomic)
```

#### Loading data from the documents directory 
```swift 
if let data = FileManager.default.contents(atPath: url.path) {
  do {
    events = try PropertyListDecoder().decode([Event].self, from: data)
  } catch {
    throw DataPersistenceError.decodingError(error)
  }
} else {
  throw DataPersistenceError.noData
}
```
