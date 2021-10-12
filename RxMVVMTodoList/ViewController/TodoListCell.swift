//
//  TodoListCell.swift
//  RxMVVMTodoList
//
//  Created by 조영우 on 2021/09/19.
//

import UIKit

class TodoListCell: UITableViewCell {
    static let identifier = "TodoListCell"
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    func updateUI(todo: Todo) {
        descriptionLabel.text = todo.detail
    }
}
