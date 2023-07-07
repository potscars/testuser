//
//  HomeViewController.swift
//  TestUser
//
//  Created by owner on 01/07/2023.
//

import UIKit
import Combine
import SwiftUI

class HomeViewController: UIViewController {
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var searchBar: UISearchBar?
    
    private var vm = HomeViewControllerViewModel()
    private var disposeBag = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupViews()
        self.vm.fetchDataFromCoreData()
        self.vm.fetchUsers()
    }
    
    private func setupViews() {
        
        searchBar = UISearchBar()
        searchBar?.sizeToFit()
        searchBar?.placeholder = "Search user..."
        searchBar?.delegate = self
        
        navigationItem.titleView = searchBar
        navigationItem.title = "Home"
        
        self.setupTableView()
        self.vmBinding()
        
        self.vm.addObserver()
    }
    
    private func vmBinding() {
        vm.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                if self.vm.isBatchUpdate {
                    self.vm.isBatchUpdate = false
                    print("Batch update!")
                    self.tableView.performBatchUpdates {
                        self.tableView.insertRows(at: self.vm.indexPathsToAdd, with: .none)
                    }
                } else {
                    print("Not batch update!")
                    self.tableView.reloadData()
                }
            }
            .store(in: &disposeBag)
        
        vm.$filteredItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &disposeBag)
        
        vm.$isConnected
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.vm.isConnected {
                    self.vm.fetchUsers()
                } else {
                    self.showAlert()
                }
            }
            .store(in: &disposeBag)
    }
    
    private func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.register(HomeUserNormalCell.self, forCellReuseIdentifier: String(describing: HomeUserNormalCell.self))
        self.tableView.register(HomeUserNoteCell.self, forCellReuseIdentifier: String(describing: HomeUserNoteCell.self))
        self.tableView.register(HomeUserInvertedCell.self, forCellReuseIdentifier: String(describing: HomeUserInvertedCell.self))
        
        self.tableView.separatorStyle = .none
    }
    
    private func navigateToUserDetail(with user: User) {
        // Assign the selected user, so that the data can be pass to detail view.
        vm.selectedUser = user.login
        let hostingVC = UIHostingController(rootView: UserDetailView(dismiss: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }).environmentObject(vm))
        hostingVC.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.pushViewController(hostingVC, animated: true)
    }
    
    deinit {
        self.vm.removeObserver()
    }
    
    private func showAlert() {
        let alertController = UIAlertController(title: "Warning", message: "There is no internet connection", preferredStyle: .alert)
        
        let okayButton = UIAlertAction(title: "Okay", style: .default)
        
        alertController.addAction(okayButton)
        
        self.present(alertController, animated: true)
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.isFiltering ? vm.filteredItems.count : vm.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = vm.isFiltering ? vm.filteredItems[indexPath.row] : vm.items[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: type(of: item).reuseIdentifier) else {
            return UITableViewCell()
        }
        
        item.configure(cell: cell)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? HomeUserNormalCell {
            self.navigateToUserDetail(with: cell.getUser())
        }
        
        if let cell = tableView.cellForRow(at: indexPath) as? HomeUserInvertedCell {
            self.navigateToUserDetail(with: cell.getUser())
        }
        
        if let cell = tableView.cellForRow(at: indexPath) as? HomeUserNoteCell {
            self.navigateToUserDetail(with: cell.getUser())
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex && self.vm.filteredItems.count == 0 {
            // print("this is the last cell")
            let spinner = UIActivityIndicatorView(style: .medium)
            spinner.startAnimating()
            spinner.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
            
            self.tableView.tableFooterView = spinner
            self.tableView.tableFooterView?.isHidden = false
            self.vm.willLoadMoreData()
        } else {
            self.tableView.tableFooterView?.isHidden = true
        }
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        vm.searchUsers(with: searchText)
    }
}
