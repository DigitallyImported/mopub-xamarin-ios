//
//  OrderPreferenceViewController.swift
//
//  Copyright 2018-2019 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

/**
 This is a multi-section table view controller for reordering items.
 */
final class OrderPreferenceViewController: UIViewController {
    struct DataSource {
        struct Section {
            let header: String?
            var items: [String]
        }
        
        let title: String
        var sections: [Section]
    }

    typealias OrderChangedHandlerResponse = (shouldDismiss: Bool, message: String?)
    typealias OrderChangedHandler = (DataSource) -> OrderChangedHandlerResponse
    
    private var dataSource: DataSource
    private let orderChangedHandler: OrderChangedHandler
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isEditing = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.className)
        return tableView
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Programmatic instantiation only")
    }
    
    private init(dataSource: DataSource, orderChangedHandler: @escaping OrderChangedHandler) {
        self.dataSource = dataSource
        self.orderChangedHandler = orderChangedHandler
        super.init(nibName: nil, bundle: nil)
        self.title = dataSource.title
        setUpView()
        modalPresentationStyle = .formSheet
    }
    
    /**
     Convenience instantiation function. Use this instead of `init`.
     */
    static func viewController(dataSource: DataSource, orderChangedHandler: @escaping OrderChangedHandler) -> UIViewController {
        let viewController = OrderPreferenceViewController(dataSource: dataSource, orderChangedHandler: orderChangedHandler)
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
}

// MARK: - UITableViewDataSource

extension OrderPreferenceViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource.sections[section].header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className, for: indexPath)
        cell.textLabel?.text = dataSource.sections[indexPath.section].items[indexPath.item]
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedItem = dataSource.sections[sourceIndexPath.section].items.remove(at: sourceIndexPath.item)
        dataSource.sections[destinationIndexPath.section].items.insert(movedItem, at: destinationIndexPath.item)
    }
}

// MARK: - UITableViewDelegate

extension OrderPreferenceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

// MARK: - Private

private extension OrderPreferenceViewController {
    func setUpView() {
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(didHitCancelButton))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done",
                                                           style: .done,
                                                           target: self,
                                                           action: #selector(didHitDoneButton))
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    @objc func didHitCancelButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didHitDoneButton() {
        let response = orderChangedHandler(dataSource)
        if response.shouldDismiss {
            dismiss(animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Sorry",
                                                    message: response.message,
                                                    preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertController, animated: true, completion: nil)
        }
    }
}
