//
//  TodoListViewController.swift
//  RxMVVMTodoList
//
//  Created by 조영우 on 2021/09/19.
//

import UIKit
import RxSwift

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
        // Do any additional setup after loading the view.

        // [x] TODO: 키보드 디텍션
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillHideNotification, object: nil)

        // [x] TODO: 데이터 불러오기
        todoListViewModel.loadTasks()
//        print(todoListViewModel.todos.map { $0.detail })

        let details = todoListViewModel.todos.map { $0.detail }
        var detailObservable: Observable<[String]>
        if details == [] {
            detailObservable = Observable.of(["123","234","345","456","567"])
        } else {
            detailObservable = Observable.of(details)
        }
        print("details: \(details)")
        
        detailObservable
            .asObservable()
            .bind(to: collectionView.rx.items(cellIdentifier: "TodoListCell", cellType: TodoListCell.self)) { index, element, cell in
                cell.backgroundColor = .blue
                print(element)
                cell.descriptionLabel.text = element
            }
            .disposed(by: disposeBag)



        collectionView.rx.itemSelected
            .subscribe(onNext: { index in
                print("Delegate : \(index.section) \(index.row) \(index.item)")
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // UICollectionViewDelegateFlowLayout
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = CGSize(width: view.bounds.width, height: 100)
        collectionView.setCollectionViewLayout(flowLayout, animated: true)
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }

    @IBAction func isTodayButtonTapped(_ sender: Any) {
        // [x] TODO: 투데이 버튼 토글 작업
        isTodayButton.isSelected = !isTodayButton.isSelected
        asdf()
    }

    @IBAction func addTaskButtonTapped(_ sender: Any) {
        guard let detail = inputTextField.text, detail.isEmpty == false else {
            self.collectionView.reloadData() // MARK: 이거 지우는 거 깜빡 ㄴㄴ
            return
        }
        let todo = TodoManager.shared.createTodo(detail: detail, isToday: isTodayButton.isSelected)
        todoListViewModel.addTodo(todo)
        collectionView.reloadData()
        inputTextField.text = ""
        isTodayButton.isSelected = false
    }

    // TODO: background tap했을때 키보드 내려오게 하기
    @IBAction func tapBG(_ sender: Any) {
        inputTextField.resignFirstResponder()
    }
}

extension TodoListViewController {
    @objc private func adjustInputView(noti: Notification) {
        guard let userInfo = noti.userInfo else { return }
        // [x] TODO: 키보드 높이에 따른 인풋뷰 위치 변경
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
