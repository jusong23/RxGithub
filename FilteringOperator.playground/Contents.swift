import RxSwift

let disposeBag = DisposeBag()
let 취침모드😴 = PublishSubject<String>()

print("----ignoreElements----")
// Next 이벤트만 무시 ! (Error나 Complete는 허용)
취침모드😴
    .ignoreElements()
    .subscribe {
    print($0)
}
    .disposed(by: disposeBag)

취침모드😴.onNext("📢")
취침모드😴.onNext("📢")
취침모드😴.onNext("📢")

취침모드😴.onCompleted()

print("----elementAt----")
// 특정 인덱스의 이벤트만 방출

let 두번울면깨는사람 = PublishSubject<String>()

두번울면깨는사람
    .element(at: 3) // 이 부분을 주석처리하면 구독한 시점 이후 이벤트만 출력!
.subscribe({
    print($0)
})
    .disposed(by: disposeBag)

두번울면깨는사람.onNext("📢")
두번울면깨는사람.onNext("📢")
두번울면깨는사람.onNext("☺️")
두번울면깨는사람.onNext("📢")

print("----filter----")
// 내가 아는 필터 (필터 내 요구사항이 여러가지 일때 !)
Observable.of(1, 2, 3, 4, 5, 6, 7, 8)
    .filter { $0 % 2 == 0 }
//    .filter{ $0 + 2 > 6 } // 필터 여러개 쓸 수 있음
.subscribe {
    print($0)
}
    .disposed(by: disposeBag)

print("----skip----")
Observable.of("가", "나", "다", "라", "마", "바", "사", "아")
    .skip(5)
    .subscribe {
    print($0)
}
    .disposed(by: disposeBag)

print("----skipWhile----")
Observable.of("가", "나", "다", "라", "마", "바", "사", "아")
    .skip(while: {
    $0 != "바"
})
    .subscribe {
    print($0)
}
    .disposed(by: disposeBag)

print("----skipUntil----")
let 손님 = PublishSubject<String>()
let 문여는시간 = PublishSubject<String>()

손님
    .skip(until: 문여는시간)
    .subscribe(onNext: {
    print($0)
})
    .disposed(by: disposeBag)

// "문여는시간"이라는 다른 옵저저블이 onNext방출하기 전까지는 Skip!

손님.onNext("☺️")
손님.onNext("☺️")
문여는시간.onNext("땡")
손님.onNext("🥸")

print("----take----")
// 몇번째 인덱스까지 할지 !(Skip의 반대개념)
Observable.of("금메달", "은메달", "동메달", "4등", "5등")
    .take(3)
    .subscribe(onNext: {
    print($0)
})
    .disposed(by: disposeBag)

print("----takeWhile----")
// 해당 element이전까지만 방출(SkipWhile의 반대개념)
Observable.of("금메달", "은메달", "동메달", "4등", "5등")
    .take(while: {
    $0 != "동메달"
}) // 동메달 이전까지만 방출
.subscribe(onNext: {
    print($0)
})
    .disposed(by: disposeBag)

print("----enumerated----")
// 3 미만의 인덱스까지, index & element를 방출 !
Observable.of("금메달", "은메달", "동메달", "4등", "5등")
    .enumerated()
    .takeWhile {
    $0.index < 3
}
    .subscribe(onNext: {
    print($0)
})
    .disposed(by: disposeBag)

print("----takeUntil----")
let 수강신청 = PublishSubject<String>()
let 신청마감 = PublishSubject<String>()

수강신청
    .take(until: 신청마감) // Trigger가 되기 '이 전'까지의 이벤트만 방출
.subscribe(onNext: {
    print($0)
})
    .disposed(by: disposeBag)

수강신청.onNext("🙋")
수강신청.onNext("🙋🏾‍♂️")

신청마감.onNext("신청이 마감되었습니다.")
수강신청.onNext("🙋‍♀️")

print("----distinctUntilChanged----")
// 반복되는 element는 하나로 압축해주는 Operator
Observable.of("저는", "저는", "앵무새", "앵무새", "입니다", "저는", "저는", "앵무새", "앵무새","일까요?","일까요?")
    .distinctUntilChanged()
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
