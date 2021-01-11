//
//  GroupsTableViewController.swift
//  SocialAppVK
//
//  Created by Алексей Морозов on 05.10.2020.
//

import UIKit
import RealmSwift

class GroupsTableViewController: UITableViewController {
    
    lazy var loadingView: UIView = {
        return LoadingView(frame: CGRect(x: view.frame.minX, y: view.frame.minY, width: view.frame.maxX, height: view.frame.maxY))
    }()
    
    var groupsData: Results<Group>!
    private var groupToken: NotificationToken?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLoadingView()
        
        tableView.register(UINib(nibName: "CustomTableViewCell", bundle: nil), forCellReuseIdentifier: "CustomTableViewCell")
        
        view.backgroundColor = Colors.background
        
        getGroupData()
    }
    
    private func setupLoadingView() {
        view.addSubview(loadingView)
        loadingView.isHidden = true
    }
    
    func getGroupData() {
        self.groupsData = DatabaseManager.shared.loadGroupData()
        self.groupToken = groupsData.observe(on: DispatchQueue.main, { [weak self] (changes) in
            guard let self = self else { return }
            
            switch changes {
            case .update(_, deletions: let deletions, insertions: let insetions, modifications: let modifications):
                self.tableView.beginUpdates()
                self.tableView.insertRows(at: insetions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                self.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                self.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                self.tableView.endUpdates()
                break
            case .initial:
                self.tableView.reloadData()
            case .error(let error):
                print("Error in \(#function). Message: \(error.localizedDescription)")
            }
        })
        
        loadGroupList() // Load new data anyways
    }
    
    private func loadGroupList() {
        NetworkManager.shared.loadGroupsList(count: 0, offset: 0) { groupsList in
            DispatchQueue.main.async {
                guard let groupsList = groupsList else { return }
                DatabaseManager.shared.deleteGroupData() // Removing all group data before loading new data from network
                DatabaseManager.shared.saveGroupData(groups: groupsList.groups) // Saving data from network to Realm
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupsData.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomTableViewCell", for: indexPath) as! CustomTableViewCell
        
        cell.setGroupCell(group: groupsData[indexPath.row])

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = GroupProfileViewController(nibName: "GroupProfileViewController", bundle: nil)
        
        let group = groupsData[indexPath.row]
        
        vc.title = group.name
        vc.getImages(group: group)
        
        self.navigationController?.pushViewController(vc, animated: true)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let group = groupsData[indexPath.row]
            let realm = try! Realm()
            try? realm.write {
                realm.delete(group)
            }
        }
    }
    
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
}
