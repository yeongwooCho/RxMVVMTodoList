////
////  TestHeader.swift
////  RxMVVMTodoList
////
////  Created by 조영우 on 2021/09/23.
////
//
//import UIKit
//import RxSwift
//import RxCocoa
//import RxDataSources
//
//
//class asdfasdf {
//    typealias TodoSectionModel = SectionModel<String, Todo>
//    typealias TodoDataSource = RxCollectionViewSectionedReloadDataSource<TodoSectionModel>
//    
//    private func bindTableView() {
//        
//        let firstCities = [
//            Todo(detail: "first 1번이야", id: 1, isDone: true, isToday: false),
//            Todo(detail: "first 2번이야", id: 2, isDone: false, isToday: false),
//            Todo(detail: "first 3번이야", id: 3, isDone: true, isToday: true),
//            Todo(detail: "first 4번이야", id: 4, isDone: false, isToday: true)
//        ]
//        let secondCities = [
//            Todo(detail: "second 1번이야", id: 5, isDone: true, isToday: false),
//            Todo(detail: "second 2번이야", id: 6, isDone: false, isToday: false),
//            Todo(detail: "second 3번이야", id: 7, isDone: true, isToday: true),
//            Todo(detail: "second 4번이야", id: 8, isDone: false, isToday: true)
//        ]
//        
//        let sections = [
//            SectionModel<String, Todo>(model: "first section", items: firstCities),
//            SectionModel<String, Todo>(model: "second section", items: secondCities)
//        ]
//        
//        Observable.just(sections)
//            .bind(to: collectionView.rx.items(dataSource: todoDatasource))
//            .disposed(by: disposedBbag)
//    }
//    
//    private var todoDatasource: TodoDataSource {
//        let configureCell: (CollectionViewSectionedDataSource<TodoSectionModel>, UICollectionView, IndexPath, Todo) -> UICollectionViewCell = { (datasource, collectionView, indexPath,  element) in
//            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TodoListCell", for: indexPath) as? TodoListCell else { return UICollectionViewCell() }
//            cell.updateUI(todo: element)
//            return cell
//        }
//        
//        let datasource = TodoDataSource.init(configureCell: configureCell)
//        
//        
//        datasource.titleForHeaderInSection = { datasource, index in
//            return datasource.sectionModels[index].model
//        }
//        
//        return datasource
//    }
//}
//
//
////private func qwerqwer() {
////    let cities = ["London", "Vienna", "Lisbon"]
////
////    let configureCell: (CollectionViewSectionedDataSource<SectionModel<String, Todo>>, UICollectionView, IndexPath, Todo) -> UICollectionViewCell = { (datasource, collectionView, indexPath, element) in
////        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TodoListCell", for: indexPath) as? TodoListCell else { return UICollectionViewCell() }
////        cell.updateUI(todo: element)
////        return cell
////    }
////
////    let datasource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, Todo>>(configureCell: configureCell)
////
////    datasource.sectionModels = datasource.sectionModels[index].model
////
////
////
////
////
////
////
////    datasource.titleForHeaderInSection = { datasource, index in
////        return datasource.sectionModels[index].model
////    }
////    datasource.
////
////    let sections = [
////        SectionModel<String, String>(model: "first section", items: cities),
////        SectionModel<String, String>(model: "second section", items: cities)
////    ]
////
////    Observable.just(sections)
////        .bind(to: tableView.rx.items(dataSource: datasource))
////        .disposed(by: bag)
////}










//    public func items<Sequence: Swift.Sequence, Cell: UITableViewCell, Source: ObservableType>
//        (cellIdentifier: String, cellType: Cell.Type = Cell.self)
//        -> (_ source: Source)
//        -> (_ configureCell: @escaping (Int, Sequence.Element, Cell) -> Void)
//        -> Disposable
//        where Source.Element == Sequence {
//        return { source in
//            return { configureCell in
//                let dataSource = RxTableViewReactiveArrayDataSourceSequenceWrapper<Sequence> { tv, i, item in
//                    let indexPath = IndexPath(item: i, section: 0)
//                    let cell = tv.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! Cell
//                    configureCell(i, item, cell)
//                    return cell
//                }
//                return self.items(dataSource: dataSource)(source)
//            }
//        }
//    }

    
//private func bindTableView1() {
//
//    let firstCities = [
//        Todo(detail: "first 1번이야", id: 1, isDone: true, isToday: false),
//        Todo(detail: "first 2번이야", id: 2, isDone: false, isToday: false),
//        Todo(detail: "first 3번이야", id: 3, isDone: true, isToday: true),
//        Todo(detail: "first 4번이야", id: 4, isDone: false, isToday: true)
//    ]
//    let secondCities = [
//        Todo(detail: "second 1번이야", id: 5, isDone: true, isToday: false),
//        Todo(detail: "second 2번이야", id: 6, isDone: false, isToday: false),
//        Todo(detail: "second 3번이야", id: 7, isDone: true, isToday: true),
//        Todo(detail: "second 4번이야", id: 8, isDone: false, isToday: true)
//    ]
//
//    let sections = [
//        TodoSectionModel(model: "first section", items: firstCities),
//        TodoSectionModel(model: "second section", items: secondCities)
//    ]
//
//    Observable.just(sections)
//        .bind(to: tableView.rx.items(dataSource: todoDatasource))
//        .disposed(by: disposeBag)
//}


//        tableView.rx.itemSelected
//            .subscribe(onNext: { [weak self] indexPath in
//                print(1)
//                guard let detailVC = UIComponents.mainStoryboard.instantiateViewController(withIdentifier: TodoDetailViewController.identifier) as? TodoDetailViewController else { return }
//                let selectedTodo = self?.todoListViewModel.output.todoList.value[indexPath.item]
//                detailVC.todoDetailViewModel.input.todoInfo.onNext(selectedTodo)
//                self?.present(detailVC, animated: true, completion: nil)
//            })
//            .disposed(by: disposeBag)

