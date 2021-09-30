//
//  TestTableViewController.swift
//  RxMVVMTodoList
//
//  Created by 조영우 on 2021/09/23.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class TestTableViewController: UIViewController {
    typealias TodoSectionModel = SectionModel<String, Todo>
    typealias TodoDataSource = RxTableViewSectionedReloadDataSource<TodoSectionModel>
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var isTodayButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var inputViewBottom: NSLayoutConstraint!
    
    let disposedBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindTableView()
    }
    
    private func bindTableView() {
        
        let firstCities = [
            Todo(detail: "first 1번이야", id: 1, isDone: true, isToday: false),
            Todo(detail: "first 2번이야", id: 2, isDone: false, isToday: false),
            Todo(detail: "first 3번이야", id: 3, isDone: true, isToday: true),
            Todo(detail: "first 4번이야", id: 4, isDone: false, isToday: true)
        ]
        let secondCities = [
            Todo(detail: "second 1번이야", id: 5, isDone: true, isToday: false),
            Todo(detail: "second 2번이야", id: 6, isDone: false, isToday: false),
            Todo(detail: "second 3번이야", id: 7, isDone: true, isToday: true),
            Todo(detail: "second 4번이야", id: 8, isDone: false, isToday: true)
        ]
        
        let sections = [
            SectionModel<String, Todo>(model: "first section", items: firstCities),
            SectionModel<String, Todo>(model: "second section", items: secondCities)
        ]
        
        Observable.just(sections)
            .bind(to: tableView.rx.items(dataSource: todoDatasource))
            .disposed(by: disposedBag)
    }
    
    private var todoDatasource: TodoDataSource {
        let configureCell: (TableViewSectionedDataSource<TodoSectionModel>, UITableView, IndexPath, Todo) -> UITableViewCell = { (datasource, tableView, indexPath, element) in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as? TableViewCell else { return UITableViewCell() }
            cell.descriptionLabel.text = element.detail
            return cell
        }
        
        let datasource = TodoDataSource.init(configureCell: configureCell)
        
        datasource.titleForHeaderInSection = { datasource, index in
            return datasource.sectionModels[index].model
        }
        return datasource
    }
}

extension TestTableViewController {
    @objc private func adjustInputView(noti: Notification) {
        guard let userInfo = noti.userInfo else { return }
        // 키보드 높이에 따른 인풋뷰 위치 변경
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }

        if noti.name == UIResponder.keyboardWillShowNotification {
            let adjustmentHeight = keyboardFrame.height - view.safeAreaInsets.bottom
            inputViewBottom.constant = adjustmentHeight
        } else {
            inputViewBottom.constant = 0
        }
        print("---> Keyboard End Frame: \(keyboardFrame)")
    }
}

class TableViewCell: UITableViewCell {
    static let identifier = "TableViewCell"
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var strikeThroughView: UIView!
    
    @IBOutlet weak var strikeThroughWidth: NSLayoutConstraint!
    
    var doneButtonTapHandler: ((Bool) -> Void)?
    var deleteButtonTapHandler: (() -> Void)?
    
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
        // [x] TODO: cell update
        checkButton.isSelected = todo.isDone
        descriptionLabel.text = todo.detail
        descriptionLabel.alpha = todo.isDone ? 0.2 : 1
        deleteButton.isHidden = todo.isDone == false
        showStrikeThrough(todo.isDone)
    }

    // 흰색 짝대기, 가림막
    private func showStrikeThrough(_ show: Bool) {
        if show {
            strikeThroughWidth.constant = descriptionLabel.bounds.width
        } else {
            strikeThroughWidth.constant = 0
        }
    }

    func reset() {
        // [x] TODO: reset logic 구현
        descriptionLabel.alpha = 1
        deleteButton.isHidden = true
        showStrikeThrough(false)
    }

    
    @IBAction func checkButtonTapped(_ sender: Any) {
        // [x] TODO: checkButton 처리
        checkButton.isSelected = !checkButton.isSelected
        let isDone = checkButton.isSelected
        descriptionLabel.alpha = isDone ? 0.2 : 1
        deleteButton.isHidden = !isDone
        showStrikeThrough(isDone)
        
        doneButtonTapHandler?(isDone)
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        // [x] TODO: deleteButton 처리
        deleteButtonTapHandler?()
    }
}


//private func bindTableView() { // section header 없이 cell로만 구성
//    todoListViewModel.output.todoList // BehaviorRelay<[Todo]>
//        // Driver은 MainScheduler에서 동작하는 UI Layer에 좀더 직관적으로 사용하도록 제공하는 Unit이다. Observable이다.
//        .asDriver(onErrorJustReturn: []) // 해당 Observable을 Driver로 변환하고, 에러가 발생하면 비어있는 비어있는 Observable로 변환
//        .drive(tableView.rx.items) { tableView, indexPath, item in // observable을 구독하고 이벤트를 받으면 binding을 한다.
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoListCell.identifier) as? TodoListCell else { return UITableViewCell()}
//            cell.updateUI(todo: item)
//            // MARK: delete button Tap Handler
//            cell.deleteButtonTapHandler = { [weak self] in
//                self?.todoListViewModel.deleteTodos(todo: item)
//            }
//            return cell
//        }
//        .disposed(by: disposeBag)
//}
