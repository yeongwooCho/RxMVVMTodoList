//
//  TodoDetailViewController.swift
//  RxMVVMTodoList
//
//  Created by 조영우 on 2021/09/23.
//

import UIKit
import RxSwift

class TodoDetailViewController: UIViewController {

    static let identifier = "TodoDetailViewController"

//    @IBOutlet weak var detailLabel: UILabel!
//    @IBOutlet weak var idLabel: UILabel!
//    @IBOutlet weak var isDoneLabel: UILabel!
//    @IBOutlet weak var isTodayLabel: UILabel!
    let detailLabel = UILabel()
    let idLabel = UILabel()
    let isDoneLabel = UILabel()
    let isTodayLabel = UILabel()
    let closeButton = UIButton()
    
    
//    let todoDetailViewModel = TodoDetailViewModel()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bindUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        closeButton
    }
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func bindUI() {
//        todoDetailViewModel.output.detail
//            .subscribe(onNext: { [weak self] detail in
//                self?.detailLabel.text = detail
//            })
//            .disposed(by: disposeBag)
//        
//        todoDetailViewModel.output.id
//            .subscribe(onNext: { [weak self] id in
//                self?.idLabel.text = String(id)
//            })
//            .disposed(by: disposeBag)
//        
//        todoDetailViewModel.output.isDone
//            .subscribe(onNext: { [weak self] isDone in
//                self?.isDoneLabel.text = String(isDone)
//            })
//            .disposed(by: disposeBag)
//        
//        todoDetailViewModel.output.isToday
//            .subscribe(onNext: { [weak self] isToday in
//                self?.isTodayLabel.text = String(isToday)
//            })
//            .disposed(by: disposeBag)
    }
}
