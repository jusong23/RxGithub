import UIKit
import RxSwift

print("----Just----")
Observable<Int>.just(1)
    .subscribe(onNext: {
    print($0)
})
// 하나

print("----Of 1----")
Observable<Int>.of(1, 2, 3, 4, 5)
    .subscribe(onNext: {
    print($0)
})
// 안에 있는 걸 순차적으로 방출

print("----Of 2----")
Observable.of([6, 7, 8, 9], [6, 7, 8, 9])
    .subscribe(onNext: {
    print($0)
})
// 안에 있는 걸 순차적으로 방출
// (타입 추론이 가능 -> 배열 통째로 방출)

print("----From----")
Observable.from([10, 11, 12])
    .subscribe(onNext: {
    print($0)
})
// "Array만" 방출 하나씩 순차적

//MARK: 어떻게 방출될까? -> Observable은 정의 일뿐 ! 추가로 subscribe 해줘야 함

print("----subscribe 1----")
Observable.of(1, 2, 3, 4)
    .subscribe {
    print($0)
}

print("----subscribe 2----")
Observable.of(1, 2, 3, 4)
    .subscribe {
    if let element = $0.element {
        print(element)
    } // element가 있을 때 에만 방출해줘 ! (onNext와 같음)
}

print("----empty----")
Observable<Void>.empty()
    .subscribe {
    print($0)
} // 즉시 종료, 0개의 값을 가지는 옵저버블 리턴할 때

print("----never----")
Observable<Void>.never()
    .debug("NEVER")
    .subscribe(
    onNext: {
        print($0)
    }, onCompleted: {
        print("Complete")
    })

print("----range----")
Observable.range(start: 1, count: 9)
    .subscribe(onNext: {
    print("2 * \($0) = \(2 * $0)")
})

print("----disposeBag----") //MARK: 자주 쓰임
// DisposeBag 타입을 이용하면
let disposeBag = DisposeBag()

Observable.of(1, 2, 3)
    .subscribe {
    print($0)
}
    .disposed(by: disposeBag)
// 자신이 할당해제 할때 모든 구독에 대해 Dispose를 날린다 (?)
// 메모리 누수 방지 !
// 생명주기라고 이해하자

print("----create 1----")
Observable.create { observer -> Disposable in
    observer.onNext(1)
    // observe.on(.next(1))
    observer.onCompleted()
    // observe.on(.completed)
    observer.onNext(2)
    return Disposables.create()
}
    .subscribe {
    print($0)
}
    .disposed(by: disposeBag)
// onCompleted(1)은 출력 X
// Observable 시퀀스를 직접 만드는 특이한 경우


print("----create 2----")
enum MyErorr: Error {
    case anError
}

Observable<Int>.create { observer -> Disposable in
    observer.onNext(1)
    observer.onError(MyErorr.anError)
    observer.onCompleted()
    observer.onNext(2)
    return Disposables.create()
}

    .subscribe(
    onNext: {
        print($0)
    }, onError: {
        print($0.localizedDescription)
    }, onCompleted: {
        print("Completed")
    }, onDisposed: {
        print("Disposed")
    })
// 각 상황에 대해 구독 ! -> 각 상황에서 이벤트가 방출했을 때 출력되도록.
.disposed(by: disposeBag)

print("----deffered 1----")
Observable.deferred({
    Observable.of(1, 2, 3)
})
    .subscribe({
    print($0)
})
    .disposed(by: disposeBag)
// Observable 안의 Observable

print("----deffered 2----")
var 뒤집기: Bool = false

let factory: Observable<String> = Observable.deferred({
    뒤집기 = !뒤집기

    if 뒤집기 {
        return Observable.of("Up")
    } else {
        return Observable.of("Down")
    }
    // Observable 시퀀스를 생성할 수 있다 !
    // 조건문에 따라 Observable을 반환할 수 있음 !

})
for _ in 0...3 {
    factory.subscribe(onNext: {
        print($0)
    })
        .disposed(by: disposeBag)
}


