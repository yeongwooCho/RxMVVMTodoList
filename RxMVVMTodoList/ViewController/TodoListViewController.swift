//
//  TodoListViewController.swift
//  RxMVVMTodoList
//
//  Created by 조영우 on 2021/09/19.
//

import UIKit
import RxCocoa
import RxSwift
import RxDataSources

class TodoListViewController: UIViewController, UIScrollViewDelegate {
    // RxCocoa 기반 TableView section header을 만들기 위해 편리한 type 지정
    typealias TodoSectionModel = SectionModel<String, Todo> // defalut로 section과 데이터를 묶기 좋다.
    typealias TodoDataSource = RxTableViewSectionedReloadDataSource<TodoSectionModel> // RxDataSources에서 제공하는 Sectioned Reload
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var inputViewBottom: NSLayoutConstraint!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var isTodayButton: UIButton!
    @IBOutlet weak var addButton: UIButton!

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
        
        // keyboard Detection
        // MARK: 이거는 Rx기반 Observable, Observer을 통한 이벤트 전달 방법 존재한지 확인하기
        // 키보드 등장, 나감을 observe하다가 발생하면 #selector에 해당하는 함수를 실행한다.
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        // MARK: // delegate 사용을 위한 선언, 솔직하게 왜있는지 모름
        tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        // Observable Event는 단방향이기 때문에 Delegate를 통해 값 가져오기가 불가능하다 이것이 rx를 이용한 tableView의 한계이다???
        // rx를 사용하면 코드가 분산이 되지 않고 한눈에 들어오게 되는 장점이 있는데, delegate는 rx를 쓰더라도 동일한 방식으로 진행된다.
        
        
        setTableView()
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
        
        todoListViewModel.fetchTodos() // request Get
        // requestGet은 Observable이고, 이를 구독하고 있다가 정상적인 Next event를 받게되면 output.todoList에 accept 시키는 동작을 한다.
    }
    
    private func setTableView() {
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
    
    func bindCollectionView() {
        todoListViewModel.output.todoList
            .asDriver(onErrorJustReturn: [])
            .drive(collectionView.rx.items) { collectionView, indexPath, item in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodoListCell.identifier, for: IndexPath(index: indexPath)) as? TodoListCell else { return UICollectionViewCell() }
                cell.updateUI(todo: item)
                // MARK: delete button Tap Handler
                cell.deleteButtonTapHandler = { [weak self] in
                    self?.todoListViewModel.deleteTodos(todo: item)
                }
                return cell
            }
            .disposed(by: disposeBag)
    }

    @IBAction func isTodayButtonTapped(_ sender: Any) {
        // 투데이 버튼 토글 작업
        isTodayButton.isSelected = !isTodayButton.isSelected
    }
    
    @IBAction func addTaskButtonTapped(_ sender: Any) {
        guard let detail = inputTextField.text, detail.isEmpty == false else { return }
        let todo = Todo(detail: detail, isToday: isTodayButton.isSelected)
        todoListViewModel.addTodos(todo: todo)
        inputTextField.text = ""
        isTodayButton.isSelected = false
    }

    // background View tap했을때 키보드 내려오게 하기
    @IBAction func tapBG(_ sender: Any) {
        inputTextField.resignFirstResponder()
    }
}

// rx 기반이 아닌 NotificationCenter에 의한 이벤트 전달방식
// MARK: rx 기반 있는지 확인하고, 적용하기
extension TodoListViewController {
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
