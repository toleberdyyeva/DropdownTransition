//
//  ViewController.swift
//  Dropdown
//
//  Created by Aidar Nugmanoff on 9/29/20.
//  Copyright © 2020 Aidar Nugmanoff. All rights reserved.
//

// @TODO static let transitioningDelegate
// @TODO handle largetitle, searchbar?

import UIKit

final class ChatListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet private weak var tableView: UITableView!
    private lazy var navigationTitleButton = NavigationTitleButtonWithArrow()
    private let dropdownTransitioningDelegate = DropdownTransitioningDelegate()
    
    private let chats: [ChatViewModel] = ChatViewModel.default

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationTitleButton.addTarget(self, action: #selector(navigationTitleButtonDidPress), for: .touchUpInside)
        navigationItem.titleView = navigationTitleButton
        navigationTitleButton.title = "Personal Chats"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
        tableView.showsVerticalScrollIndicator = false
        tableView.register(UINib(nibName: "ChatCell", bundle: nil), forCellReuseIdentifier: "ChatCell")
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView()
        setupNavigationBar()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell", for: indexPath) as! ChatCell
        cell.configure(with: chats[indexPath.row])
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let animation = AnimationFactory.makeMoveUpWithFade(rowHeight: cell.frame.height, duration: 0.5, delayFactor: 0.05)
        let animator = Animator(animation: animation)
        animator.animate(cell: cell, at: indexPath, in: tableView)
    }
    
    private func setupNavigationBar() {
        self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
    }
    
    @objc private func navigationTitleButtonDidPress() {
        UIView.animate(withDuration: 0.2) {
            self.navigationTitleButton.toggleArrow()
        }
        if presentedViewController != nil {
            navigationController?.dismiss(animated: true, completion: nil)
            tableView.reloadData()
        } else {
            presentChatFolderListViewController()
        }
    }
    
    private func presentChatFolderListViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let chatFolderListViewController = storyboard.instantiateViewController(identifier: "ChatFolderListViewController") as! ChatFolderListViewController
        chatFolderListViewController.onDidDismiss = { chatFolderName in
            UIView.animate(withDuration: 0.2) {
                self.navigationTitleButton.toggleArrow()
            }
            self.navigationTitleButton.setTitle(chatFolderName, for: .normal)
            self.tableView.reloadData()
        }
        chatFolderListViewController.transitioningDelegate = dropdownTransitioningDelegate
        chatFolderListViewController.modalPresentationStyle = .custom
        navigationController?.present(chatFolderListViewController, animated: true, completion: nil)
    }
}
