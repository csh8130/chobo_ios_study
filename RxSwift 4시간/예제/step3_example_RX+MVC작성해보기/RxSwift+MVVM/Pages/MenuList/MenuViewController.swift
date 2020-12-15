//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import UIKit
import RxSwift

class MenuViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchMenus()
        refreshTotal()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier ?? ""
        if identifier == "OrderViewController",
            let orderVC = segue.destination as? OrderViewController {
            orderVC.orderedMenuItems = items.filter { $0.count > 0 }
        }
    }

    func showAlert(_ title: String, _ message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertVC, animated: true, completion: nil)
    }
    
    // MARK: business logic
    var items: [(menu: MenuItem, count: Int)] = []
    
    func fetchMenus() {
        activityIndicator.isHidden = false
//        APIService.fetchAllMenus { [weak self] result in
//            guard let self = self else {
//                return
//            }
//            switch result {
//            case .success(let data):
//                struct Response: Decodable {
//                    let menus: [MenuItem]
//                }
//                guard let response = try? JSONDecoder().decode(Response.self, from: data) else {
//                    self.showAlert("error", "json decode error")
//                    DispatchQueue.main.async {
//                        self.activityIndicator.isHidden = true
//                    }
//                    return
//                }
//                self.items = response.menus.map { ($0, 0) }
//                DispatchQueue.main.async {
//                    self.activityIndicator.isHidden = true
//                    self.tableView.reloadData()
//                }
//            case .failure(let error):
//                print(error)
//                break
//            }
//        }
        let observable = APIService.fetchAllMenusRx()
        observable.subscribe { event in
            switch event {
            case let .next(data):
                struct Response: Decodable {
                    let menus: [MenuItem]
                }
                
                guard let data = event.element, let response = try? JSONDecoder().decode(Response.self, from: data) else {
                    print("error")
                    DispatchQueue.main.async {
                        self.showAlert("error", "json decode error")
                        self.activityIndicator.isHidden = true
                    }
                    return
                }
                
                self.items = response.menus.map { ($0, 0) }
                DispatchQueue.main.async {
                    self.activityIndicator.isHidden = true
                    self.tableView.reloadData()
                }
            default:
                break
            }
        }.disposed(by: disposeBag)
    }
    
    func refreshTotal() {
        let allCount = items.map { $0.count }.reduce(0, +)
        let allPrice = items.map { $0.count * $0.menu.price}.reduce(0, +)
        itemCountLabel.text = "\(allCount)"
        totalPrice.text = allPrice.currencyKR()
    }

    // MARK: - InterfaceBuilder Links

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var itemCountLabel: UILabel!
    @IBOutlet var totalPrice: UILabel!

    @IBAction func onClear() {
        items = items.map { ($0.menu, 0) }
        tableView.reloadData()
        refreshTotal()
    }

    @IBAction func onOrder(_ sender: UIButton) {
        let allCount = items.map { $0.count }.reduce(0, +)
        guard allCount > 0 else {
            showAlert("Order Fail", "No Orders")
            return
        }
        
        performSegue(withIdentifier: "OrderViewController", sender: nil)
    }
}

extension MenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemTableViewCell") as! MenuItemTableViewCell
        cell.item = items[indexPath.row]
        cell.onCountChanged = { [weak self] inc in
            guard let self = self else {
                return
            }
            
            var count = (cell.item?.count ?? 0) + inc
            if count < 0 {
                count = 0
            }
            self.items[indexPath.row].count = count
            cell.item = self.items[indexPath.row]
            tableView.beginUpdates()
            tableView.reloadRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
            self.refreshTotal()
        }
        return cell
    }
}
