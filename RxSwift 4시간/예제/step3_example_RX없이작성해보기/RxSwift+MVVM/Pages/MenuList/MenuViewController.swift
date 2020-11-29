//
//  ViewController.swift
//  RxSwift+MVVM
//
//  Created by iamchiwon on 05/08/2019.
//  Copyright © 2019 iamchiwon. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchMenus()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier ?? ""
        if identifier == "OrderViewController",
            let orderVC = segue.destination as? OrderViewController {
            // TODO: pass selected menus
        }
    }

    func showAlert(_ title: String, _ message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertVC, animated: true, completion: nil)
    }
    
    // MARK: business logic
    var items: [MenuItem] = []
    
    func fetchMenus() {
        activityIndicator.isHidden = false
        APIService.fetchAllMenus { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let data):
                struct Response: Decodable {
                    let menus: [MenuItem]
                }
                guard let response = try? JSONDecoder().decode(Response.self, from: data) else {
                    self.showAlert("error", "json decode error")
                    DispatchQueue.main.async {
                        self.activityIndicator.isHidden = true
                    }
                    return
                }
                self.items = response.menus
                DispatchQueue.main.async {
                    self.activityIndicator.isHidden = true
                    self.tableView.reloadData()
                }
            case .failure(let error):
                print(error)
                break
            }
        }
    }

    // MARK: - InterfaceBuilder Links

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var itemCountLabel: UILabel!
    @IBOutlet var totalPrice: UILabel!

    @IBAction func onClear() {
    }

    @IBAction func onOrder(_ sender: UIButton) {
        // TODO: no selection
        // showAlert("Order Fail", "No Orders")
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
        return cell
    }
}
