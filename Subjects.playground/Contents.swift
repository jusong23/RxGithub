import RxSwift

let disposeBag = DisposeBag()

print("----publishSubject----")
let publishSubject = PublishSubject<String>()

publishSubject.onNext("1. 여러분 안녕하세요.") //MARK: 1번 다이아그램
// * 옵저버의 특정
// 이벤트를 내 뱉을 수 있다.
// 구독을 해야만 의미가 있다.

let 구독자1 = publishSubject //MARK: 1번 다이아그램 보다 늦게 구독을 시작
.subscribe(onNext: {
    print($0)
})

publishSubject.onNext("첫번째 구독자: 2. 들리시나요") //MARK: 구독한 후
publishSubject.onNext("첫번째 구독자: 3. 안 들리세요?") //MARK: 구독한 후

구독자1.dispose()

let 구독자2 = publishSubject //MARK: 1번 다이아그램 보다 늦게 구독을 시작
.subscribe(onNext: {
    print($0)
})

publishSubject.onNext("두번째 구독자: 4. 여보세요")
publishSubject.onCompleted()

publishSubject.onNext("두번째 구독자: 5. 끝났나요")

구독자2.dispose()

//MARK: publishSubject - 이벤트를 놓치고 구독하면 받을 수 없다!
//onCompleted 이벤트가 마무리 되었기에 아무도 들을 수 없다.

let 구독자3 = publishSubject
    .subscribe {
    print("세번째 구독자:", $0.element ?? $0)
}
    .disposed(by: disposeBag)

publishSubject.onNext("6. 찍힐까요?")

print("----behaviorSubject----")
enum SubjectError: Error {
    case error1
}

let behaviorSubject = BehaviorSubject<String>(value: "초기값")

behaviorSubject.onNext("1. 첫번째 값")

behaviorSubject.subscribe {
    print("첫번째 구독: ", $0.element ?? $0)
}
    .disposed(by: disposeBag)

//behaviorSubject.onError(SubjectError.error1)

behaviorSubject.subscribe {
    print("두번째 구독: ", $0.element ?? $0)
}
    .disposed(by: disposeBag)
// 구독 직후의 '직전 값'을 방출 한다 !

//Observable<Int>.of(1, 2, 3, 4, 5)
//    .subscribe(onNext: {
//    print($0)
//})
// 위 처럼 Observable의 값만 뽑아 낼 수 있다.
let value = try? behaviorSubject.value().count
print(value) // onNext 안의 값을 뽑아낼 수 있는 것이다
// 잘 쓰지는 않음

print("----ReplaySubject----")
let replaySubject = ReplaySubject<String>.create(bufferSize: 3) // 버퍼사이즈 먼저 선언

replaySubject.onNext("1. 여러분")
replaySubject.onNext("2. 힘내세요")
replaySubject.onNext("3. 어렵지만")

replaySubject.subscribe {
    print("첫번째 구독:", $0.element ?? $0)
}
    .disposed(by: disposeBag)

replaySubject.subscribe {
    print("두번째 구독:", $0.element ?? $0)
}
    .disposed(by: disposeBag)

replaySubject.onNext("4. 할수있어요")
replaySubject.onError(SubjectError.error1)
replaySubject.dispose()

replaySubject.subscribe {
    print("세번째 구독:", $0.element ?? $0)
}
    .disposed(by: disposeBag)

