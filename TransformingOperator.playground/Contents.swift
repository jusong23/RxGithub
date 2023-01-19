import RxSwift

let disposeBag = DisposeBag()

print("----toArray----")
Observable.of("A", "B", "C")
    .toArray() // 얘를 맥이면 Single Type으로 변한다.
.subscribe(
    onSuccess: {
        print($0)
    })
    .disposed(by: disposeBag)
// of를 통해 각각에 넣었던 element들이 single타입의 Array로 변한다!

print("----map----")
Observable.of(Date())
    .map { date -> String in
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    dateFormatter.locale = Locale(identifier: "ko_KR")
    return dateFormatter.string(from: date)
}
    .subscribe(onNext: {
    print($0)
})
    .disposed(by: disposeBag)

print("----flatMap----")
// 중첩된 옵저버블 [[String]]
protocol 선수 {
    var 점수: BehaviorSubject<Int> { get } //프로퍼티 선언
}

struct 양궁선수: 선수 {
    var 점수: BehaviorSubject<Int>
}

let KOR = 양궁선수(점수: BehaviorSubject<Int>(value: 10)) // 초기값 가진채로 시작(직전 값 방출)
let USA = 양궁선수(점수: BehaviorSubject<Int>(value: 8)) // 초기값 가진채로 시작(직전 값 방출)

let 올림픽경기 = PublishSubject < 선수 > () // 빈 상태로 시작하여 새로운 값만을 Subscriber에게 방출

// 중첩된 옵저버블을 핸들링하고 싶을때 -> flatMap

올림픽경기
    .flatMap { 선수 in
    선수.점수
}
    .subscribe({
    print($0) // 구독을 시작
})
    .disposed(by: disposeBag)

올림픽경기.onNext(KOR)
KOR.점수.onNext(10)

올림픽경기.onNext(USA)
KOR.점수.onNext(10)
USA.점수.onNext(9)

print("----flatMapLatest----")
// 이후에 변경된 값을 무시한다.
// 네트워크에서 검색할 때, 가장 새로운 값에 맞춰 리스트를 내릴 때 사용 (ex. swift 검색)
struct 높이뛰기선수: 선수 {
    var 점수: BehaviorSubject<Int>
}

let 서울 = 높이뛰기선수(점수: BehaviorSubject<Int>(value: 7))
let 제주 = 높이뛰기선수(점수: BehaviorSubject<Int>(value: 6))

let 전국체전 = PublishSubject < 선수 > () // 전국체전 (서울 , 제주)

전국체전
    .flatMapLatest { 선수 in
    선수.점수
}
    .subscribe({
    print($0) // 구독을 시작
})
    .disposed(by: disposeBag)

전국체전.onNext(서울)
서울.점수.onNext(9)

전국체전.onNext(제주)
서울.점수.onNext(10)
제주.점수.onNext(8)

print("----materialize and dematerialize----")
enum 반칙: Error {
    case 부정출발
}

struct 달리기선수: 선수 {
    var 점수: BehaviorSubject<Int>
}

let 김토끼 = 달리기선수(점수: BehaviorSubject<Int>(value: 0))
let 박치타 = 달리기선수(점수: BehaviorSubject<Int>(value: 1))

let 달리기100M = BehaviorSubject < 선수 > (value: 김토끼)

달리기100M
    .flatMapLatest { 선수 in
    선수.점수
        .materialize() // 이벤트까지 보여지는 출력 방식 !
}
    .filter {
    guard let error = $0.error else {
        return true
    }
    print(error)
    return false // 에러 가졌을때 필터를 통과시켜 에러를 출력!
}
    .dematerialize() // 이벤트 출력은 무시
.subscribe(onNext: {
    print($0)
})
    .disposed(by: disposeBag)

김토끼.점수.onNext(1)
김토끼.점수.onError(반칙.부정출발)
김토끼.점수.onNext(2) // 가장 초기값 1만 출력되고 반칙 뒤에꺼는 출력 X

달리기100M.onNext(박치타)

print("----전화번호 11자리----")
let input = PublishSubject<Int?>()

let list: [Int] = [1]

input
    .flatMap {
    $0 == nil ? Observable.empty() : Observable.just($0)
}
    .map { $0! } // 옵셔널 처리
.skip(while: { $0 != 0 }) // 0이 나올때 까지 Skip!
.take(11) // 11개만 받으라.
.toArray() // 이것들을 Array로 만들어줌
.asObservable() // toArray거치며 Single로 된거를 Observable로 변경
.map {
    $0.map { "\($0)" }
}
    .map { numbers in
    var numberList = numbers
    numberList.insert("-", at: 3)
    numberList.insert("-", at: 8)
    let number = numberList.reduce(" ", +)
    return number
}
    .subscribe(onNext: {
    print($0)
})
    .disposed(by: disposeBag)

input.onNext(10)
input.onNext(0)
input.onNext(nil)
input.onNext(1)
input.onNext(0)
input.onNext(4)
input.onNext(5)
input.onNext(2)
input.onNext(3)
input.onNext(0)
input.onNext(4)
input.onNext(5)
input.onNext(0)
input.onNext(nil)
input.onNext(0)
