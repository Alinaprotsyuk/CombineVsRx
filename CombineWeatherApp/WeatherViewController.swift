//
//  NewViewController.swift
//  CombineWeatherApp
//
//  Created by Alina Protsiuk on 14.02.2020.
//  Copyright © 2020 CoreValue. All rights reserved.
//

import UIKit
import Combine
import RxSwift
import RxCocoa

class WeatherViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var viewModel = WeatherViewModel()
    
    var dataSource: UITableViewDiffableDataSource<Section, WeatherRowViewModel>!
    
    var data = [WeatherRowViewModel]() {
        didSet {
            createSnapshot()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if DEBUG
            doCombineMethods()
        #else
            doRxMethods()
        #endif
    }

}

//MARK: - Combine Framework
extension WeatherViewController {
    func doCombineMethods() {
        setupDiffableTableView()
        
        viewModel.$data
            .print("ViewModel")
            .assign(to: \.data, on: self)
            .store(in: &viewModel.cancellable)
        
        NotificationCenter.Publisher(center: .default,
                                     name: UITextField.textDidChangeNotification, object: searchBar.searchTextField)
            .map({ ($0.object as? UITextField)?.text ?? ""})
            .sink(receiveValue: { (value) in
                self.viewModel.fetchData(for: value)
            })
            .store(in: &viewModel.cancellable)
    }
}

//MARK: - RxSwift Framework
extension WeatherViewController {
    func doRxMethods() {
        searchBar.rx.text.orEmpty
            .throttle(.microseconds(3000), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] (text) in
                self?.viewModel.fetchRxData(for: text)
            })
            .disposed(by: viewModel.disposeBag)
        
        
        viewModel.listData.bind(to: tableView.rx.items(cellIdentifier: "Cell")) { (index, model, cell) in
            cell.textLabel?.text = model.fullDescription
            cell.detailTextLabel?.text = model.temperature
            if let iconName = model.icon {
                cell.imageView?.loadWithRx(icon: iconName)
                    .map({ $0 == true })
                    .subscribeOn(MainScheduler.instance)
                    .subscribe({ (_) in
                        self.tableView.reloadData()
                    })
                    .disposed(by: self.viewModel.disposeBag)
            }
        }
        .disposed(by: viewModel.disposeBag)
    }
}

//MARK: - UITableViewDiffableDataSource
extension WeatherViewController {
    enum Section {
        case main
    }
    
    func setupDiffableTableView() {
        dataSource = UITableViewDiffableDataSource<Section, WeatherRowViewModel>(tableView: tableView,
                                                                                 cellProvider: { (tableView, indexPath, item) -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
            cell?.textLabel?.text = item.fullDescription
            cell?.detailTextLabel?.text = item.temperature
            if let name = item.icon {
                cell?.imageView?.loadWithCombine(icon: name)
            }
            return cell
        })
    }
    
    func createSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, WeatherRowViewModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(data)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}



