//
//  TodoListViewController.swift
//  RxMVVMTodoList
//
//  Created by 조영우 on 2021/09/19.
//

import UIKit
import RxCocoa
import RxSwift
import RxGesture
import RxDataSources
import RxKeyboard

class TodoListViewController: UIViewController, UIScrollViewDelegate {
    static let identifier = "TodoListViewController"
    
    // RxCocoa 기반 TableView section header을 만들기 위해 편리한 type 지정
    typealias TodoSectionModel = SectionModel<String, Todo> // defalut로 section과 데이터를 묶기 좋다.
    typealias TodoDataSource = RxTableViewSectionedReloadDataSource<TodoSectionModel> // RxDataSources에서 제공하는 Sectioned Reload
    
    @IBOutlet weak var tableView: UITableView!

    let todoListViewModel = TodoViewModel() // 여기서 ViewModel 생성, View는 ViewModel을 갖고있다.
    let disposeBag = DisposeBag() // 구독한 뒤 더이상 사용 안하면 리소스 반환하는 쓰레기통
    
    private var todoDatasource: TodoDataSource { // RxTableViewSectionedReloadDataSource< SectionModel<String, Todo> >
        // closure이며 뒤의 3개 파라미터는 datasource에 필요한 cell 구성을 만들기 위함이다.
        let configureCell: (TableViewSectionedDataSource<TodoSectionModel>, UITableView, IndexPath, Todo) -> UITableViewCell = { (datasource, tableView, indexPath, element) in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: TodoListCell.identifier, for: indexPath) as? TodoListCell else { return UITableViewCell() }
            cell.updateUI(todo: element)
            cell.completedButtonTapHandler = { // [weak self] in
//                self?.todoListViewModel.deleteTodos(todo: element)
                print("completed")
            }
            return cell
        }
        // cell은 datasource에 사용할 정보를 모두 담고 있고, 이를 datasource에 맞게 initialize를 거친다.
        // TodoDataSource 객체를 만드는 것이고, 이는 위의 클로저 파라미터로 TableViewSectionedDataSource를 선언해야 하는 이유이다.
        let datasource = TodoDataSource.init(configureCell: configureCell)
        datasource.titleForHeaderInSection = { ds, index in return ds.sectionModels[index].model }
        datasource.canMoveRowAtIndexPath = { ds, index in return true }
        datasource.canEditRowAtIndexPath = { ds, index in return true }
        return datasource
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        tableView.setEditing(true, animated: true)
        setupTableView()
        sectionHeaderBindTableView()
        setupItemEditing() // deleted, moved
        todoListViewModel.fetchTodos() // request Get
    }
    
    private func setupTableView() {
        let refreshControl = UIRefreshControl() // 뷰를 아래로 당겨서 새로고침을 제공
        tableView.refreshControl = refreshControl
        
        // Control Event type
        refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: todoListViewModel.input.reloadTrigger) // PublishSubject<Void>
            .disposed(by: disposeBag)
        
        self.todoListViewModel.output.refreshing // BehaviorSubject<Bool>
            .subscribe(onNext: { [weak self] refreshing in
                if refreshing { return } // refreshing이 true이면 계속 구독
                self?.tableView.refreshControl?.endRefreshing() // 새로고침 종료를 의미
            }) // output.refreshing 값이 바꼈다는 것은 정상적으로 데이터를 Get했다는 것
            .disposed(by: disposeBag)
    }
    
    private func sectionHeaderBindTableView() {
        self.todoListViewModel.output.sectionTodoList
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(dataSource: self.todoDatasource))
            .disposed(by: self.disposeBag)
        
    }
    
    private func setupItemEditing() {
        tableView.rx.itemDeleted
            .subscribe (onNext: { [weak self] deleteItem in
                self?.todoListViewModel.deleteTodos(at: deleteItem)
            })
            .disposed(by: disposeBag)
        
        tableView.rx.itemMoved
            .subscribe(onNext: { [weak self] moveItem in
                print("move from \(moveItem.sourceIndex) to \(moveItem.destinationIndex)")
                if moveItem.sourceIndex == moveItem.destinationIndex {
                    guard let detailVC = UIComponents.mainStoryboard.instantiateViewController(withIdentifier: TodoDetailViewController.identifier) as? TodoDetailViewController else { return }
                    let selectedTodo = self?.todoListViewModel.output.sectionTodoList.value[moveItem.sourceIndex.section].items[moveItem.sourceIndex.item]
                    detailVC.todoDetailViewModel.input.todoInfo.onNext(selectedTodo)
                    self?.present(detailVC, animated: true, completion: nil)
                } else { // move로 인한 실제 데이터 값 변경으로 section이 변경되어야함.
                    let sourceItem = self?.todoListViewModel.output.sectionTodoList.value[moveItem.sourceIndex.section].items[moveItem.sourceIndex.item]
                    let destinationSection = self?.todoListViewModel.output.sectionTodoList.value[moveItem.destinationIndex.section].model
                    guard let obj = sourceItem, let deadlineDate = destinationSection else { return }
                    self?.todoListViewModel.updateTodos(obj: obj, deadlineDate: deadlineDate)
                }
            })
            .disposed(by: disposeBag)
    }
}
