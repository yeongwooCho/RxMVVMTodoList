//
//  TodoListCell.swift
//  RxMVVMTodoList
//
//  Created by 조영우 on 2021/09/19.
//

import UIKit

class TodoListCell: UITableViewCell {
    static let identifier = "TodoListCell"
    
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var strikeThroughView: UIView!
    @IBOutlet weak var strikeThroughWidth: NSLayoutConstraint!
    
    var deleteButtonTapHandler: (() -> Void)?
    
    // 셀이 화면에서 깨어날 때
    override func awakeFromNib() {
        super.awakeFromNib()
        reset()
    }
    
    // 재사용되는 셀의 속성을 초기화 하는 과정
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    func updateUI(todo: Todo) {
        checkButton.isSelected = todo.isDone
        descriptionLabel.text = todo.detail
        descriptionLabel.alpha = todo.isDone ? 0.2 : 1
        deleteButton.isHidden = todo.isDone == false
        showStrikeThrough(todo.isDone)
    }
    
    // check가 되었을 때, 등장하는 가림막 view의 width 변경
    private func showStrikeThrough(_ show: Bool) {
        if show {
            strikeThroughWidth.constant = descriptionLabel.bounds.width
        } else {
            strikeThroughWidth.constant = 0
        }
    }
    
    private func reset() {  // check 가 아닌 본래의 상태
        descriptionLabel.alpha = 1
        deleteButton.isHidden = true
        showStrikeThrough(false)
    }
    
    @IBAction func checkButtonTapped(_ sender: Any) {
        checkButton.isSelected = !checkButton.isSelected
        let isDone = checkButton.isSelected
        descriptionLabel.alpha = isDone ? 0.2 : 1
        deleteButton.isHidden = !isDone
        showStrikeThrough(isDone)
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        deleteButtonTapHandler?()
    }
}
