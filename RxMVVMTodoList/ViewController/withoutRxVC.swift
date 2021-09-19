//
//  withoutRxVC.swift
//  RxMVVMTodoList
//
//  Created by 조영우 on 2021/09/19.
//



//import UIKit
//import RxSwift
//
//class TodoListViewController: UIViewController {
//    @IBOutlet weak var collectionView: UICollectionView!
//    @IBOutlet weak var inputViewBottom: NSLayoutConstraint!
//    @IBOutlet weak var inputTextField: UITextField!
//
//    @IBOutlet weak var isTodayButton: UIButton!
//    @IBOutlet weak var addButton: UIButton!
//
//    // [x]TODO: TodoViewModel 만들기
//    let todoListViewModel = TodoViewModel()
//    let disposeBag = DisposeBag()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//
//        // [x] TODO: 키보드 디텍션
//        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillHideNotification, object: nil)
//
//        // [x] TODO: 데이터 불러오기
//        todoListViewModel.loadTasks()
//
//    }
//
//    @IBAction func isTodayButtonTapped(_ sender: Any) {
//        // [x] TODO: 투데이 버튼 토글 작업
//        isTodayButton.isSelected = !isTodayButton.isSelected
//        asdf()
//    }
//
//    @IBAction func addTaskButtonTapped(_ sender: Any) {
//        guard let detail = inputTextField.text, detail.isEmpty == false else {
//            self.collectionView.reloadData() // MARK: 이거 지우는 거 깜빡 ㄴㄴ
//            return
//        }
//        let todo = TodoManager.shared.createTodo(detail: detail, isToday: isTodayButton.isSelected)
//        todoListViewModel.addTodo(todo)
//        collectionView.reloadData()
//        inputTextField.text = ""
//        isTodayButton.isSelected = false
//    }
//
//    // TODO: background tap했을때 키보드 내려오게 하기
//    @IBAction func tapBG(_ sender: Any) {
//        inputTextField.resignFirstResponder()
//    }
//}
//
//extension TodoListViewController {
//    @objc private func adjustInputView(noti: Notification) {
//        guard let userInfo = noti.userInfo else { return }
//        // [x] TODO: 키보드 높이에 따른 인풋뷰 위치 변경
//        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
//
//        if noti.name == UIResponder.keyboardWillShowNotification {
//            let adjustmentHeight = keyboardFrame.height - view.safeAreaInsets.bottom
//            inputViewBottom.constant = adjustmentHeight
//        } else {
//            inputViewBottom.constant = 0
//        }
//        print("---> Keyboard End Frame: \(keyboardFrame)")
//    }
//}
//
//extension TodoListViewController: UICollectionViewDataSource {
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        // [x] TODO: 섹션 몇개?
//        return todoListViewModel.numOfSection
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        // [x] TODO: 섹션별 아이템 몇개?
//        if section == 0 {
//            return todoListViewModel.todayTodos.count
//        } else {
//            return todoListViewModel.upcomingTodos.count
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TodoListCell", for: indexPath) as? TodoListCell else {
//            return UICollectionViewCell()
//        }
//
//        var todo: Todo
//        if indexPath.section == 0 {
//            todo = todoListViewModel.todayTodos[indexPath.item]
//        } else {
//            todo = todoListViewModel.upcomingTodos[indexPath.item]
//        }
//        cell.updateUI(todo: todo)
//        cell.doneButtonTapHandler = { isDone in
//            todo.isDone = isDone
//            self.todoListViewModel.updateTodo(todo)
//            self.collectionView.reloadData()
//        }
//        cell.deleteButtonTapHandler = {
//            self.todoListViewModel.deleteTodo(todo)
//            self.collectionView.reloadData()
//        }
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        switch kind {
//        case UICollectionView.elementKindSectionHeader:
//            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "TodoListHeaderView", for: indexPath) as? TodoListHeaderView else {
//                return UICollectionReusableView()
//            }
//
//            guard let section = TodoViewModel.Section(rawValue: indexPath.section) else {
//                return UICollectionReusableView()
//            }
//
//            header.sectionTitleLabel.text = section.title
//            return header
//        default:
//            return UICollectionReusableView()
//        }
//    }
//}
//
//extension TodoListViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        // TODO: 사이즈 계산하기
//        let width: CGFloat = collectionView.bounds.width
//        let height: CGFloat = 50
//        return CGSize(width: width, height: height)
//    }
//}
