# Getting Started with Core Data Tutorial

이번 [튜토리얼](https://www.raywenderlich.com/7569-getting-started-with-core-data-tutorial)에서는 나만의 메모 리스트를 저장하는 예제를 만들게 됩니다.



**Core Data 개요**

- Core Data는 영구적으로 데이터를 저장하기위해 사용할 Framework 다.

- Core Data는 데이터 저장을 위해서 내부적으로 SQLite 데이터베이스를 사용합니다. (SQLite 외에 다른것을 사용 할 수도 있다.)

- 일반적으로 간단한 데이터를 영구저장하는경우 UserDefaults를 복잡한 데이터를 저장할 경우 Core Data를 이용합니다.
  
  

**Core Data 시작하기**

이 프로젝트에서 Core Data를 사용 할 것이므로 프로젝트를 생성할 때 Use Core Data를 체크합니다.

만약 프로젝트 생성시에 Use Core Data를 체크하지 않았다면 아래의 두가지를 프로젝트에 직접 추가 해야 합니다.

1. Data Model 파일이 생성됩니다.
   
   > ![image](https://user-images.githubusercontent.com/25359605/92460884-7a5d9b00-f203-11ea-956f-ee41736d942b.png)
   > 
   > *.xcdatamodeld 데이터 모델 파일이 생성됩니다. Core Data는 기본적으로 SQLite DB를 사용하므로 여기서 model은 데이터베이스의 schema와 동일한 개념입니다.
   > 
   > 
   > 
   > !![image](https://user-images.githubusercontent.com/25359605/92460845-69ad2500-f203-11ea-9b4b-893abb2e8fb1.png)
   > 
   > 모델 편집기에서 Entity를 추가할 수 있습니다. Entity는 Core data에 저장하기위한 데이터의 구조를 정의합니다.

2. AppDelegate에 persistentContainer를 생성합니다. 컨테이너는 CoreData를 사용하기위한 boilerplate code를 위한 변수입니다. 우리는 CoreData를 사용해서 데이터를 저장하거나 불러올때 이 컨테이너 변수를 사용하면 됩니다.





**테이블뷰와 버튼 생성**

1. 데이터를 저장하기위한 Add  버튼과 사용자에게 보여줄 테이블뷰를 추가합니다.
   
   데이터는 name: [String] 배열을 만들어서 저장합니다.
   
   ```swift
   var names: [String] = []
   ```
   
   방금만든 배열을 테이블뷰 데이터소스에 추가합니다.
   
   ```swift
   // MARK: - UITableViewDataSource
   extension ViewController: UITableViewDataSource {
     
     func tableView(_ tableView: UITableView,
                    numberOfRowsInSection section: Int) -> Int {
       return names.count
     }
     
     func tableView(_ tableView: UITableView,
                    cellForRowAt indexPath: IndexPath)
                    -> UITableViewCell {
   
       let cell =
         tableView.dequeueReusableCell(withIdentifier: "Cell",
                                       for: indexPath)
       cell.textLabel?.text = names[indexPath.row]
       return cell
     }
   }
   
   ```

!![image](https://user-images.githubusercontent.com/25359605/92460898-7e89b880-f203-11ea-8882-b6c624a1ac9c.png)

2. Add 버튼을 누르면 사용자에게 입력을 받도록 Alert을 추가합니다.
   
   ```swift
   // Implement the addName IBAction
   @IBAction func addName(_ sender: UIBarButtonItem) {
     
     let alert = UIAlertController(title: "New Name",
                                   message: "Add a new name",
                                   preferredStyle: .alert)
     
     let saveAction = UIAlertAction(title: "Save",
                                    style: .default) {
       [unowned self] action in
                                     
       guard let textField = alert.textFields?.first,
         let nameToSave = textField.text else {
           return
       }
       
       self.names.append(nameToSave)
       self.tableView.reloadData()
     }
     
     let cancelAction = UIAlertAction(title: "Cancel",
                                      style: .cancel)
     
     alert.addTextField()
     
     alert.addAction(saveAction)
     alert.addAction(cancelAction)
     
     present(alert, animated: true)
   }
   ```

아래와 같이 입력받은 내용을 보여주는 메모 앱을 완성시킵니다.

![image](https://user-images.githubusercontent.com/25359605/92460905-821d3f80-f203-11ea-989f-87187ef7d71c.png)

아직까지 데이터 저장을 위한 Core Data를 사용하지 않았습니다. 앱을 강제종료하고 다시 실행하면 리스트가 모두 사라지게됩니다. Core Data를 사용하여 입력받은 데이터를 저장하도록 하겠습니다.



**Core Data Model 편집**

![image](https://user-images.githubusercontent.com/25359605/92460917-85183000-f203-11ea-9511-d6dd78198f1a.png)

Data Model 파일을 클릭해서 Model 편집기를 엽니다. 편집기의 Add Entity 버튼을 눌러 Entity를 추가하고 이름을 Person으로 바꿉니다.



![image](https://user-images.githubusercontent.com/25359605/92460830-644fda80-f203-11ea-83d5-339c2278d038.png)

Person Entity에 name attribute를 추가하고 데이터 타입을 String으로 지정합니다.

Core Data의 Entity는 Swift에서 class와 매칭되는 개념으로 생각해도 무방합니다. Person class에 name필드에 데이터를 저장합니다.



**Core Data 데이터 저장**

Core Data를 사용하기 위해 Import 합니다.

```swift
import CoreData
```

데이터 소스로 사용한 names 배열을 다음과 같이 바꿉니다.

```swift
var people: [NSManagedObject] = []
```

NSManagedObject는 CoreData에 저장된 단일 객체를 의미합니다.

Entity가 Swift의 Class와 같은 개념이었다면, ManagedObject는 Swift의 인스턴스라고 생각 할 수 있습니다.



이전에 구현했던 데이터소스 메서드도 변경해야합니다.

```swift
// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView,
                 numberOfRowsInSection section: Int) -> Int {
    return people.count
  }

  func tableView(_ tableView: UITableView,
                 cellForRowAt indexPath: IndexPath)
                 -> UITableViewCell {

    let person = people[indexPath.row]
    let cell =
      tableView.dequeueReusableCell(withIdentifier: "Cell",
                                    for: indexPath)
    cell.textLabel?.text =
      person.value(forKeyPath: "name") as? String
    return cell
  }
}

```

ManagedObject에서 name attribute를 가져올 때는 아래와같은 코드를 사용했습니다

```swift
cell.textLabel?.text =
  person.value(forKeyPath: "name") as? String
```

Dictonary를 사용하는것과 동일한 메커니즘으로 사용하게 됩니다.



데이터를 영구적으로 저장하기위한 save 함수를 만듭니다.

```swift
func save(name: String) {
  
  guard let appDelegate =
    UIApplication.shared.delegate as? AppDelegate else {
    return
  }
  
  // 1
  let managedContext =
    appDelegate.persistentContainer.viewContext
  
  // 2
  let entity =
    NSEntityDescription.entity(forEntityName: "Person",
                               in: managedContext)!
  
  let person = NSManagedObject(entity: entity,
                               insertInto: managedContext)
  
  // 3
  person.setValue(name, forKeyPath: "name")
  
  // 4
  do {
    try managedContext.save()
    people.append(person)
  } catch let error as NSError {
    print("Could not save. \(error), \(error.userInfo)")
  }
}
```

// 1 프로젝트 생성시에 자동 생성되었던 persistentContainer에 접근하여 Context를 얻습니다.

// 2 DataModel에서 정의한 Person Entity를 가져와서 ManagedObject를 생성합니다.

// 3 ManagedObject에 저장할 값을 할당합니다.

// 4 Context의 save를 호출하여 저장을 마칩니다.



데이터 영구저장을 위한 코드를 완성했습니다. 다음으로 데이터를 불러오는 코드를 작성합니다.



**Core Data 데이터 불러오기**

```swift
override func viewWillAppear(_ animated: Bool) {
  super.viewWillAppear(animated)
  
  //1
  guard let appDelegate =
    UIApplication.shared.delegate as? AppDelegate else {
      return
  }
  
  let managedContext =
    appDelegate.persistentContainer.viewContext
  
  //2
  let fetchRequest =
    NSFetchRequest<NSManagedObject>(entityName: "Person")
  
  //3
  do {
    people = try managedContext.fetch(fetchRequest)
  } catch let error as NSError {
    print("Could not fetch. \(error), \(error.userInfo)")
  }
}
```

// 1 데이터 저장할 때와 마찬가지로 처음에 Context를 얻습니다.

// 2 이름에서 알 수 있듯이 CoreData의 Person Entity에 가져오기 요청입니다.

// 3 Context의 fetch를 호출하여 데이터를 가져옵니다



**키포인트**

- Core Data는 **on-disk persistence** 을 제공하므로 앱을 종료하거나 기기를 종료 한 후에도 데이터에 액세스 할 수 있습니다.
-  `NSManagedObjectContext`에서 `save()`또는 `fetch(_:)`를 이용하여 데이터를 저장하거나 불러옵니다.


