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

class TodoListViewController: UIViewController, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var inputViewBottom: NSLayoutConstraint!
    @IBOutlet weak var inputTextField: UITextField!

    @IBOutlet weak var isTodayButton: UIButton!
    @IBOutlet weak var addButton: UIButton!

    // [x]TODO: TodoViewModel 만들기
    let todoListViewModel = TodoViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // keyboard Detection
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
