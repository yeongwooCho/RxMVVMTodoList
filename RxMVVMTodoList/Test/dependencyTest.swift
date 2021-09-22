//
//  dependencyTest.swift
//  RxMVVMTodoList
//
//  Created by 조영우 on 2021/09/19.
//



//import Foundation
//// B가 A에 의존적인 상태를 교체해서 의존에 대한 독립을 만들겠다.
//// --> A와 B 모두 추상화에 의존해야한다.
//// --> 세부사항이 추상화에 의존해야 한다.
//
//// 의존 관계를 독립시킬 인터페이스
//protocol DependencyIndependentInterface: AnyObject {
//    var number: Int { get set }
//}
//
//// 그냥 평범하지만 위의 인터페이스에 의존관계가 있는 클래스
//class AClass: DependencyIndependentInterface {
//    var number: Int = 1
//}
//
//// AClass와 의존관계가 있는 클래스
//class BClass {
//    var internalVariable: DependencyIndependentInterface
//
//    init(WithExternalVariable variable: DependencyIndependentInterface) {
//        self.internalVariable = variable
//    }
//}
//
//let b = BClass(WithExternalVariable: AClass())
//print(b.internalVariable.number)


protocol DependencyIndependentInterface {
    var num: Int { get set }
}

class A: DependencyIndependentInterface {
    var num: Int = 1
}

class B {
    var check: DependencyIndependentInterface
    
    init(check: DependencyIndependentInterface) {
        self.check = check
    }
}

func asdf() {
    let zxcv = B.init(check: A())
    print(zxcv.check.num)
}


class NetworkManager {
  // 네트워크 요청 수행
}


class ImageLoader {
  var networkManager: NetworkManager = NetworkManager()
}
