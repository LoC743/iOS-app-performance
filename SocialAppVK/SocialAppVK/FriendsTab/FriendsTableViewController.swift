//
//  FriendsTableViewController.swift
//  SocialAppVK
//
//  Created by Алексей Морозов on 05.10.2020.
//

import UIKit
import RealmSwift

class FriendsTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!

    var friendsData: Results<User>!
    var friendToken: NotificationToken?
    
    var sections: [String] = ["Важные", "Все"]
    var importantFriends: [User] = []
    var otherFriends: [User] = []
    
    var operationQueue = OperationQueue()
    
    private let reuseIdentifier = "CustomTableViewCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        tableView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        
        view.backgroundColor = Colors.background
        tableView.sectionIndexBackgroundColor = Colors.background
        setupRefreshControl()
        
//        getUserData()
        loadFriendDataWithOperation()
    }
    
    private func loadFriendDataWithOperation() {
        guard let request = NetworkManager.shared.loadFriendListOperation(count: 0, offset: 0)  else { return }
        operationQueue.qualityOfService = .utility
        
        loadDatabaseData()
        
        let getDataOperation = GetDataOperation(request: request)
        let parseOperation = ParseUserDataOperation()
        parseOperation.addDependency(getDataOperation)
        let reloadDataOperation = ReloadTableDataOperation(controller: self)
        reloadDataOperation.addDependency(parseOperation)
        operationQueue.addOperation(getDataOperation)
        operationQueue.addOperation(parseOperation)
        OperationQueue.main.addOperation(reloadDataOperation)
    }
    
    private func setupRefreshControl() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.tintColor = Colors.brand
        tableView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    
    @objc func handleRefreshControl() {
        loadFriendList()
        resetTableData()

        // Dismiss the refresh control.
           DispatchQueue.main.async {
              self.tableView.refreshControl?.endRefreshing()
           }
    }
    
    func resetTableData() {
        sections = ["Важные", "Все"]
        importantFriends = []
        otherFriends = []
        getSectionData()
    }
    
    private func getSectionData() {
        if friendsData.count > 5 {
            for (index, friend) in friendsData.enumerated() {
                if index > 4 {
                    otherFriends.append(friend)
                } else {
                    importantFriends.append(friend)
                }
            }
        } else {
            for friend in friendsData {
                importantFriends.append(friend)
            }
        }
        
        self.tableView.reloadData()
    }
    
    private func loadDatabaseData() {
        self.friendsData = DatabaseManager.shared.loadUserData()
        
        resetTableData()
        
        self.friendToken = friendsData.observe(on: DispatchQueue.main, { [weak self] (changes) in
            guard let self = self else { return }
            
            switch changes {
            case .update:
                self.resetTableData()
                break
            case .initial:
                self.resetTableData()
            case .error(let error):
                print("Error in \(#function). Message: \(error.localizedDescription)")
            }
        })
    }
    
    private func loadFriendList() {
        NetworkManager.shared.loadFriendList(count: 0, offset: 0) { friendList in
            DispatchQueue.main.async {
                guard let friendList = friendList else { return }
                DatabaseManager.shared.deleteUserData() // Removing all user data before loading new data from network
                DatabaseManager.shared.saveUserData(users: friendList.friends) // Saving data from network to Realm
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return importantFriends.count
        } else {
            return otherFriends.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! CustomTableViewCell
        
        
        var user: User?
        if indexPath.section == 0 {
            user = importantFriends[indexPath.row]
        } else {
            user = otherFriends[indexPath.row]
        }
        
        guard let userToSet = user else { return UITableViewCell() }

        cell.setFriendCell(friend: userToSet)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UserProfileViewController(nibName: "UserProfileViewController", bundle: nil)
        
        var user: User?
        if indexPath.section == 0 {
            user = importantFriends[indexPath.row]
        } else {
            user = otherFriends[indexPath.row]
        }
        
        guard let userToSet = user else { return }
        
        vc.title = userToSet.name
        vc.getImages(user: userToSet)
        
        self.navigationController?.pushViewController(vc, animated: true)

    }
    
    // MARK: - Custom Section View

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeight: CGFloat = 60
        let viewFrame: CGRect = CGRect(x: 0, y: 0, width: tableView.frame.width, height: viewHeight)
        let view = UIView(frame: viewFrame)

        view.backgroundColor = Colors.background

        let sectionLabelFrame: CGRect = CGRect(x: 15, y: 0, width: 100, height: viewHeight/2)
        let sectionLabel = UILabel(frame: sectionLabelFrame)
        sectionLabel.textAlignment = .left
        sectionLabel.font = .systemFont(ofSize: 16)
        sectionLabel.textColor = Colors.brand
        sectionLabel.text = sections[section]
        
        if section == 1 {
            let numberOfFirendsFrame: CGRect = CGRect(x: 50, y: 0, width: 100, height: viewHeight/2)
            let numberOfFirendsLabel = UILabel(frame: numberOfFirendsFrame)
            numberOfFirendsLabel.textAlignment = .left
            numberOfFirendsLabel.font = .systemFont(ofSize: 14)
            numberOfFirendsLabel.textColor = .gray
            numberOfFirendsLabel.text = "\(friendsData.count)"
            view.addSubview(numberOfFirendsLabel)
            
        }
        
        view.addSubview(sectionLabel)

        return view
    }
    
    // MARK: Cell animation
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Before animation
        cell.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        cell.alpha = 0.0
        
        // Animation
        UIView.animate(withDuration: 1.0) {
            cell.transform = .identity
            cell.alpha = 1.0
        }
    }
    
    // MARK: - SearchBar setup
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        sections = ["Поиск"]
        importantFriends = []
        otherFriends = []
        
        if searchText.isEmpty {
            resetTableData()
        } else {
            for friend in friendsData {
                let searchString = searchText.lowercased()
                if friend.firstName.lowercased().starts(with: searchString) || friend.lastName.lowercased().starts(with: searchString) {
                    importantFriends.append(friend)
                }
            }
            tableView.reloadData()
        }
    }
}
