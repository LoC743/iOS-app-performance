//
//  GroupSearchTableViewController.swift
//  SocialAppVK
//
//  Created by Алексей Морозов on 11.10.2020.
//

import UIKit

class GroupSearchTableViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var groups: [Group] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.delegate = self

        tableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomTableViewCell")
        
        view.backgroundColor = Colors.background
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! CustomTableViewCell
        
        cell.setGroupCell(group: groups[indexPath.row])

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = GroupProfileViewController(nibName: "GroupProfileViewController", bundle: nil)
        
        let group = groups[indexPath.row]
        
        vc.title = group.name
        vc.getImages(group: group)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - SearchBar setup
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NetworkManager.shared.getGroupsBy(searchRequest: searchText, count: 25, offset: 0) { [weak self] groupsList in
            DispatchQueue.main.async {
                guard let self = self,
                      let groupsList = groupsList else { return }
                self.groups = groupsList.groups
                self.tableView.reloadData()
            }
        }
    }

}
