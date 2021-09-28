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
        
        setCollectionView() // collection
        bindCollectionView()
        todoListViewModel.fetchTodos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setLayout() // FlowLayout: cell size
    }
    
    func setCollectionView() {
        let refreshControl = UIRefreshControl()
        collectionView.refreshControl = refreshControl
        
        refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: todoListViewModel.input.reloadTrigger) // PublishSubject<Void>
            .disposed(by: disposeBag)
        
        self.todoListViewModel.output.refreshing // BehaviorSubject<Bool>
            .subscribe(onNext: { [weak self] refreshing in
                if refreshing { return } // refreshing is true
                self?.collectionView.refreshControl?.endRefreshing()
            })
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
                    self?.todoListViewModel.fetchTodos() 
                }
                return cell
            }
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                print(1)
                guard let detailVC = UIComponents.mainStoryboard.instantiateViewController(withIdentifier: TodoDetailViewController.identifier) as? TodoDetailViewController else { return }
                let selectedTodo = self?.todoListViewModel.output.todoList.value[indexPath.item]
                detailVC.todoDetailViewModel.input.todoInfo.onNext(selectedTodo)
                self?.present(detailVC, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    func setLayout() {
        // UICollectionViewDelegateFlowLayout
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: view.bounds.width, height: 70)
        collectionView.setCollectionViewLayout(flowLayout, animated: true)
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }

    @IBAction func isTodayButtonTapped(_ sender: Any) {
        // 투데이 버튼 토글 작업
        isTodayButton.isSelected = !isTodayButton.isSelected
    }

    // MARK: 여기 수정해야함
    @IBAction func addTaskButtonTapped(_ sender: Any) {
        guard let detail = inputTextField.text, detail.isEmpty == false else { return }
//        let todo = TodoManager.shared.createTodo(detail: detail, isToday: isTodayButton.isSelected)
//        todoListViewModel.addTodo(todo)
//        collectionView.reloadData()
        let todo = Todo(detail: detail, isToday: isTodayButton.isSelected)
        todoListViewModel.putTodos(todo: todo)
        todoListViewModel.fetchTodos()
        inputTextField.text = ""
        isTodayButton.isSelected = false
    }

    // background View tap했을때 키보드 내려오게 하기
    @IBAction func tapBG(_ sender: Any) {
        inputTextField.resignFirstResponder()
    }
}

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
