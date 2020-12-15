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
        setupBindings()
        fetchMenus()
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
            .do (
                onError: { [weak self] err in
                    self?.showAlert("Fetch Fail", err.localizedDescription)
                },
                onDispose: { [weak self] in
                    self?.activityIndicator.isHidden = true
                    self?.tableView.refreshControl?.endRefreshing()
                })
            .take(1)
            .bind(to: menus)
            .disposed(by: disposeBag)
    }
    
    // MARK: - UI Logic
    func setupBindings() {
        
        //당겨서 새로고침
        let refreshControl = UIRefreshControl()
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: fetchMenus)
            .disposed(by: disposeBag)
        tableView.refreshControl = refreshControl
        
        //테이블 뷰
        menus.bind(to: tableView.rx.items(cellIdentifier: "MenuItemTableViewCell", cellType: MenuItemTableViewCell.self)) { row, element, cell in
            cell.item = element
            cell.onCountChanged = { [weak self] inc in
                guard let self = self else {
                    return
                }
                
                var count = (cell.item?.count ?? 0) + inc
                if count < 0 {
                    count = 0
                }
                var currentItems = self.menus.value
                currentItems[row].count = count
                self.menus.accept(currentItems)
            }
        }
        .disposed(by: disposeBag)
        
        //선택된 아이템 총 개수
        menus.map { $0.map { $0.count }.reduce(0, +) }
            .map { "\($0)" }
            .bind(to: itemCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        //총 가격
        menus.map { $0.map { $0.menu.price * $0.count }.reduce(0, +) }
            .map { $0.currencyKR() }
            .bind(to: totalPrice.rx.text)
            .disposed(by: disposeBag)
        
        //clear 버튼 누를 때
        clearButton.rx.tap
            .withLatestFrom(menus)
            .map { $0.map { ($0.menu, 0) }}
            .bind(to: menus)
            .disposed(by: disposeBag)
        
        //order 버튼 누를 때
        orderButton.rx.tap
            .withLatestFrom(menus)
            .map { $0.map { $0.count }.reduce(0, +) }   //갯수 체크
            .do(onNext: { [weak self] count in          //갯수 0개이하이면 중지
                if count <= 0 {
                    self?.showAlert("Order Fail", "No Orders")
                }
            })
            .filter { $0 > 0 }
            .subscribe(onNext: { [weak self] _ in
                self?.performSegue(withIdentifier: "OrderViewController", sender: nil)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - InterfaceBuilder Links

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var itemCountLabel: UILabel!
    @IBOutlet var totalPrice: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var orderButton: UIButton!
}
