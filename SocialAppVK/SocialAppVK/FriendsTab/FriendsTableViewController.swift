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
    
    var importantFriends: [User] = []
    var otherFriends: [User] = []
    
    private let reuseIdentifier = "CustomTableViewCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        tableView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        
        view.backgroundColor = Colors.background
        tableView.sectionIndexBackgroundColor = Colors.background
        
        getUserData()
    }
    
    private func getSections() {
        importantFriends = []
        otherFriends = []
        
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
    
    private func getUserData() {
        self.friendsData = DatabaseManager.shared.loadUserData()
        
        getSections()
        
        self.friendToken = friendsData.observe(on: DispatchQueue.main, { [weak self] (changes) in
            guard let self = self else { return }
            
            switch changes {
            case .update:
                self.getSections()
                break
            case .initial:
                self.getSections()
            case .error(let error):
                print("Error in \(#function). Message: \(error.localizedDescription)")
            }
        })
        
        loadFriendList() // Load new data anyways
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
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return importantFriends.count
        } else {
            return otherFriends.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection
                                section: Int) -> String? {
        if section == 0 {
            return "Важные"
        } else {
            return "Все \(otherFriends.count)"
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
        
        cell.setValues(item: userToSet)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "FriendsCollectionViewController") as! FriendsCollectionViewController
        
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

        view.backgroundColor = Colors.background.withAlphaComponent(0.9)

        let sectionLabelFrame: CGRect = CGRect(x: 15, y: 0, width: 100, height: viewHeight/2)
        let sectionLabel = UILabel(frame: sectionLabelFrame)
        sectionLabel.textAlignment = .left
        sectionLabel.font = .systemFont(ofSize: 16)
        sectionLabel.textColor = Colors.text
        
        if section == 0 {
            sectionLabel.text = "Важные"
        } else {
            sectionLabel.text = "Все"
            
            let numberOfFirendsFrame: CGRect = CGRect(x: 50, y: 0, width: 100, height: viewHeight/2)
            let numberOfFirendsLabel = UILabel(frame: numberOfFirendsFrame)
            numberOfFirendsLabel.textAlignment = .left
            numberOfFirendsLabel.font = .systemFont(ofSize: 14)
            numberOfFirendsLabel.textColor = Colors.text.withAlphaComponent(0.8)
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
    
//    func resetSearchTableViewData() {
//        searchSections = sections
//        searchData = userData
//    }
    
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        searchData = [:]
//        searchSections = []
//        var sectionSearchSet: Set<Character> = []
//
//        if searchText.isEmpty {
//            resetSearchTableViewData()
//        } else {
//            for section in sections {
//                let userArray = userData[section] ?? []
//
//                for user in userArray {
//                    if user.name.lowercased().contains(searchText.lowercased()) {
//                        if searchData[section] == nil {
//                            searchData[section] = []
//                        }
//                        sectionSearchSet.insert(section)
//                        searchData[section]?.append(user)
//                    }
//                }
//            }
//
//            searchSections = Array(sectionSearchSet).sorted()
//         }
//
//        self.tableView.reloadData()
//    }
}
