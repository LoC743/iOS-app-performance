//
//  NewsTableViewController.swift
//  SocialAppVK
//
//  Created by Алексей Морозов on 16.10.2020.
//

import UIKit
import Alamofire

class NewsTableViewController: UITableViewController {
    
    private let reuseIdentifier = "NewsTableViewCell"
    
    var newsArray: [News] = []
    var groups: [Group] = []
    var nextFrom = ""
    var isLoading = false
    var request: Request?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.prefetchDataSource = self

        tableView.register(UINib(nibName: reuseIdentifier, bundle: nil), forCellReuseIdentifier: reuseIdentifier)

        tableView.backgroundColor = Colors.background
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "To Top", style: .plain, target: self, action: #selector(topButtonTapped))
        
        setupRefreshControl()
        loadNews {}
    }
    
    @objc func topButtonTapped() {
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    private func setupRefreshControl() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.tintColor = Colors.brand
        tableView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }
    
    @objc func handleRefreshControl() {
        loadNews() { [weak self] in
            guard let self = self else { return }
            
            // Dismiss the refresh control.
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
            }
        }

    }
    
    private func loadNews(completion: @escaping () -> Void) {
        self.request = NetworkManager.shared.loadFeed(count: 25, from: "") { [weak self] (feedResponse) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.newsArray = feedResponse.newsArray
                self.groups = feedResponse.groups
                self.nextFrom = feedResponse.nextFrom
                self.tableView.reloadData()
                completion()
            }
        }
    }
    
    private func loadNextNews() {
        print(#function)
        self.request = NetworkManager.shared.loadFeed(count: 15, from: nextFrom) { [weak self] (feedResponse) in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.newsArray += feedResponse.newsArray
                self.groups += feedResponse.groups
                self.nextFrom = feedResponse.nextFrom
                self.isLoading = false
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NewsTableViewCell

        var groupToSet = Group()
        let newsPost = newsArray[indexPath.item]
        
        for group in groups {
            if group.id == newsPost.sourceID || -group.id == newsPost.sourceID {
                groupToSet = group
                break;
            }
        }
        
        cell.setValues(item: newsPost, group: groupToSet)
        cell.mainScreen = self

        return cell
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tableWidth = tableView.bounds.width
        let news = self.newsArray[indexPath.section]
        
        if let photo = news.photo {
            let cellHeight = tableWidth * photo.aspectRatio
            return cellHeight
        }
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        tableView.endUpdates()
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
}

extension NewsTableViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let maxIndex = indexPaths.max()?.row ?? 0
        if maxIndex == newsArray.count - 1, !isLoading {
            isLoading = true
            loadNextNews()
        }
    }

    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        let maxIndex = indexPaths.max()?.row ?? 0
        if maxIndex == newsArray.count - 1, isLoading {
            self.request?.cancel()
        }
    }
    
}
