//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

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
            let items = menus.value.filter { $0.count > 0 }
            orderVC.orderedMenuItems = items.filter { $0.count > 0 }
        }
    }

    func showAlert(_ title: String, _ message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertVC, animated: true, completion: nil)
    }
    
    // MARK: business logic
//    var items: [(menu: MenuItem, count: Int)] = []
    let menus: BehaviorRelay<[(menu: MenuItem, count: Int)]> = BehaviorRelay(value: [])
    
    func fetchMenus() {
        activityIndicator.isHidden = false
        
        APIService.fetchAllMenusRx()
            .map { data -> [(menu: MenuItem, count: Int)] in
                struct Response: Decodable {
                    let menus: [MenuItem]
                }
                guard let res = try? JSONDecoder().decode(Response.self, from: data) else {
                    throw NSError(domain: "json decode error", code: -1, userInfo: nil)
                }
                return res.menus.map { ($0, 0) }
            }
            .observeOn(MainScheduler.instance)
            .subscribe (
                onNext: { [weak self] items in
                    self?.menus.accept(items)
                    self?.tableView.reloadData()
                },
                onError: { [weak self] err in
                    self?.showAlert("Fetch Fail", err.localizedDescription)
                },
                onDisposed: { [weak self] in
                    self?.activityIndicator.isHidden = true
                    self?.tableView.refreshControl?.endRefreshing()
                })
            .disposed(by: disposeBag)
    }
    
    func refreshTotal() {
        let items = menus.value
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
        menus.accept(menus.value.map { ($0.0, 0) })
        tableView.reloadData()
        refreshTotal()
    }

    @IBAction func onOrder(_ sender: UIButton) {
        let items = menus.value
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
        return menus.value.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemTableViewCell") as! MenuItemTableViewCell
        cell.item = menus.value[indexPath.row]
        cell.onCountChanged = { [weak self] inc in
            guard let self = self else {
                return
            }
            
            var count = (cell.item?.count ?? 0) + inc
            if count < 0 {
                count = 0
            }
            var currentItems = self.menus.value
            currentItems[indexPath.row].count = count
            self.menus.accept(currentItems)
            
            tableView.beginUpdates()
            tableView.reloadRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
            self.refreshTotal()
        }
        return cell
    }
}
