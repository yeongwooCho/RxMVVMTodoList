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
            cell.deleteButtonTapHandler = { [weak self] in
                self?.todoListViewModel.deleteTodos(todo: element)
            }
            return cell
        }
        // cell은 datasource에 사용할 정보를 모두 담고 있고, 이를 datasource에 맞게 initialize를 거친다.
        // TodoDataSource 객체를 만드는 것이고, 이는 위의 클로저 파라미터로 TableViewSectionedDataSource를 선언해야 하는 이유이다.
        let datasource = TodoDataSource.init(configureCell: configureCell)
        // datasource에는 section header을 정의할 수 있고, sectionModels의 index에 해당하는 model을 title로 지정한다.
        datasource.titleForHeaderInSection = { ds, index in
            // TodoSectionModel의 모델에 해당하는 String을 이용한다.
            return ds.sectionModels[index].model
        }
        return datasource
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // MARK: // delegate 사용을 위한 선언, 솔직하게 왜있는지 모름
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        // Observable Event는 단방향이기 때문에 Delegate를 통해 값 가져오기가 불가능하다 이것이 rx를 이용한 tableView의 한계이다???
        // rx를 사용하면 코드가 분산이 되지 않고 한눈에 들어오게 되는 장점이 있는데, delegate는 rx를 쓰더라도 동일한 방식으로 진행된다.
        
        
        setupTableView()
        // table view setting하는 것으로 tableView를 뷰 아래로 당기면 valueChanged가 일어난다.
        // 이는 Control Event type이며, 이를 구독하고 있다가 이벤트를 받게되면 input.reloadTrigger에 전달한다. 안쓰면 쓰레기통
        // output.refreshing는 구독 전 데이터도 이벤트로 보낼수 있는 BehaviorSubject이다.
        // 여기 값이 false이면 refreshing가 완료됨을 TableView에 이벤트로 전달한다.
        // 사실 이게되려면 input.reloadTrigger가 이벤트를 받는 것과 output.refreshing가 true, false 바뀌는게 연관성이 있어야함.
        // --> 이게 ViewModel의 private func setReloadTrigger 이다.
        
//        bindTableView() // no section
        // output.todoList는 BehaviorRelay<[Todo]>이고, binding 할 데이터 이기에 이기에 error 이벤트를 전달하지 않는다.
        // .asDriver(onErrorJustReturn: []) 그래서 여기에 에러가 발생하면 []를 리턴하고, 아니면 [Todo]를 Driver 타입으로 반환한다.
        // .drive(tableView.rx.items) observable을 구독하는 것이다. 이벤트를 받으면 tableview rx items에 binding을 한다.
        
        
        sectionHeaderBindTableView() // yes section
        // 일반적인 TableView의 사용은 위와같이 간단하다. 하지만, section Header을 binding할 경우 Delegate patten을 사용해야 한다.
        // viewModel.output.todoList를 구독하다가 이벤트가 발생하면 viewModel.output.sectionTodoList에 이벤트를 전달한다.
        // viewModel.output.sectionTodoList 또한 구독중이다. 이벤트가 발생하면 tableView rx items의 datasource에 binding 한다.
        // todoList가 BehaviorSubject역할을 하고, sectionTodoList가 BehaviorRelay 역할을 한다.
        // 하지만, Delegate patten 을 빼는경우 section header를 수정할 수도 있어서 일단 이렇게 진행했다.
        
        setupItemSelected()
        
        todoListViewModel.fetchTodos() // request Get
        // requestGet은 Observable이고, 이를 구독하고 있다가 정상적인 Next event를 받게되면 output.todoList에 accept 시키는 동작을 한다.
        
//        setupInputViewHandler() // input view button handler, tap gesture, keyboard detection
        
//        let todo1 = Todo(detail: "1안녀하세요", isDone: true, startDate: "2020-01-01", deadlineDate: "2021-02-01")
//        let todo2 = Todo(detail: "2안녀하세요", isDone: false, startDate: "2020-04-01", deadlineDate: "2021-05-01")
//        let todo3 = Todo(detail: "3안녀하세요", isDone: true, startDate: "2020-07-01", deadlineDate: "2021-08-01")
//        let todo4 = Todo(detail: "4안녀하세요", isDone: false, startDate: "2020-10-01", deadlineDate: "2021-11-01")
//        todoListViewModel.addTodos(todo: todo1)
//        todoListViewModel.addTodos(todo: todo2)
//        todoListViewModel.addTodos(todo: todo3)
//        todoListViewModel.addTodos(todo: todo4)
        
    }
    
    private func setupTableView() {
        let refreshControl = UIRefreshControl() // 뷰를 아래로 당겨서 새로고침을 제공
        tableView.refreshControl = refreshControl
        
        // Control Event type
        refreshControl.rx.controlEvent(.valueChanged) // 뷰를 아래로 당기면 reloadTrigger에게 이벤트를 보내 네트워크 콜을 요청한다
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
        // sectionTodoList를 구독하여 이벤트를 받으면 binding 시킨다.
        // MARK: 이거 MainScheduler 사용하도록 Relay와 Driver를 사용하도록 변경.
        self.todoListViewModel.output.sectionTodoList
            .asDriver(onErrorJustReturn: [])
            .drive(self.tableView.rx.items(dataSource: self.todoDatasource))
            .disposed(by: self.disposeBag)
        
        var todays: TodoSectionModel = TodoSectionModel.init(model: "Today", items: [])
        var upcoming: TodoSectionModel = TodoSectionModel.init(model: "Upcoming", items: [])
        
        // todoList를 구독하고 있다. todos 값이 존재함을 확인하면 sectionTodoList에 accept하여 바로 위의 binding을 실행한다.
        todoListViewModel.output.todoList
            .subscribe(onNext: { todos in
                if todos == [] { // 이게 진짜 없는건지 늦게 불러서 없는 건지가 애매함!!
                    todays = TodoSectionModel(model: "Today", items: [])
                    upcoming = TodoSectionModel(model: "Upcoming", items: [Todo(detail: "할일이 없음", isToday: false)])
                } else {
                    todays = TodoSectionModel(model: "Today", items: todos.filter{ $0.isToday == true })
                    upcoming = TodoSectionModel(model: "Upcoming", items: todos.filter{ $0.isToday == false })
                }
                self.todoListViewModel.output.sectionTodoList.accept([todays, upcoming]) // 처음값 초기화
                // 이렇게 되면 sectionTodoList의 이벤트가 발생하고 이는 위의 sectionTodoList를 구독하는 코드로 이벤트가 전달된다.
            }, onError: { error in
                print("error: \(error.localizedDescription)")
            }, onCompleted: {
                print("completed")
            }, onDisposed: {
                print("disposed")
            })
            .disposed(by: disposeBag)
    }
    
    
    
    private func setupItemSelected() {
        tableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                guard let detailVC = UIComponents.mainStoryboard.instantiateViewController(withIdentifier: TodoDetailViewController.identifier) as? TodoDetailViewController else { return }
                let selectedTodo = self?.todoListViewModel.output.todoList.value[indexPath.item]
                detailVC.todoDetailViewModel.input.todoInfo.onNext(selectedTodo)
                detailVC.modalPresentationStyle = .fullScreen
                self?.present(detailVC, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupInputViewHandler() {
        
        isTodayButton.rx.tap // 이벤트 대상
            .asDriver()
            .drive(onNext: { [weak self] in // UI binding에 해당
                self?.isTodayButton.isSelected = !((self?.isTodayButton.isSelected)!)
            })
            .disposed(by: disposeBag)
        
        addButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let detail = self?.inputTextField.text, detail.isEmpty == false else { return }
                let todo = Todo(detail: detail, isToday: self?.isTodayButton.isSelected ?? false)
                self?.todoListViewModel.addTodos(todo: todo)
                self?.inputTextField.text = ""
                self?.isTodayButton.isSelected = false
            })
            .disposed(by: disposeBag)
        
        inputTextField.resignFirstResponder()
        
//        self.view.rx
//            .tapGesture()
//            .when(.recognized)
//            .subscribe(onNext: { [weak self] _ in // 어차피 viewDidLoad에서 사용해서 MainThread로 동작한다.
////                guard let self = self else { return }
//                self?.inputTextField.resignFirstResponder()
//            })
//            .disposed(by: disposeBag)
//    }
}
