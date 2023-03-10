import RxSwift

let disposeBag = DisposeBag()
let ์ทจ์นจ๋ชจ๋๐ด = PublishSubject<String>()

print("----ignoreElements----")
// Next ์ด๋ฒคํธ๋ง ๋ฌด์ ! (Error๋ Complete๋ ํ์ฉ)
์ทจ์นจ๋ชจ๋๐ด
    .ignoreElements()
    .subscribe {
    print($0)
}
    .disposed(by: disposeBag)

์ทจ์นจ๋ชจ๋๐ด.onNext("๐ข")
์ทจ์นจ๋ชจ๋๐ด.onNext("๐ข")
์ทจ์นจ๋ชจ๋๐ด.onNext("๐ข")

์ทจ์นจ๋ชจ๋๐ด.onCompleted()

print("----elementAt----")
// ํน์  ์ธ๋ฑ์ค์ ์ด๋ฒคํธ๋ง ๋ฐฉ์ถ

let ๋๋ฒ์ธ๋ฉด๊นจ๋์ฌ๋ = PublishSubject<String>()

๋๋ฒ์ธ๋ฉด๊นจ๋์ฌ๋
    .element(at: 3) // ์ด ๋ถ๋ถ์ ์ฃผ์์ฒ๋ฆฌํ๋ฉด ๊ตฌ๋ํ ์์  ์ดํ ์ด๋ฒคํธ๋ง ์ถ๋ ฅ!
.subscribe({
    print($0)
})
    .disposed(by: disposeBag)

๋๋ฒ์ธ๋ฉด๊นจ๋์ฌ๋.onNext("๐ข")
๋๋ฒ์ธ๋ฉด๊นจ๋์ฌ๋.onNext("๐ข")
๋๋ฒ์ธ๋ฉด๊นจ๋์ฌ๋.onNext("โบ๏ธ")
๋๋ฒ์ธ๋ฉด๊นจ๋์ฌ๋.onNext("๐ข")

print("----filter----")
// ๋ด๊ฐ ์๋ ํํฐ (ํํฐ ๋ด ์๊ตฌ์ฌํญ์ด ์ฌ๋ฌ๊ฐ์ง ์ผ๋ !)
Observable.of(1, 2, 3, 4, 5, 6, 7, 8)
    .filter { $0 % 2 == 0 }
//    .filter{ $0 + 2 > 6 } // ํํฐ ์ฌ๋ฌ๊ฐ ์ธ ์ ์์
.subscribe {
    print($0)
}
    .disposed(by: disposeBag)

print("----skip----")
Observable.of("๊ฐ", "๋", "๋ค", "๋ผ", "๋ง", "๋ฐ", "์ฌ", "์")
    .skip(5)
    .subscribe {
    print($0)
}
    .disposed(by: disposeBag)

print("----skipWhile----")
Observable.of("๊ฐ", "๋", "๋ค", "๋ผ", "๋ง", "๋ฐ", "์ฌ", "์")
    .skip(while: {
    $0 != "๋ฐ"
})
    .subscribe {
    print($0)
}
    .disposed(by: disposeBag)

print("----skipUntil----")
let ์๋ = PublishSubject<String>()
let ๋ฌธ์ฌ๋์๊ฐ = PublishSubject<String>()

์๋
    .skip(until: ๋ฌธ์ฌ๋์๊ฐ)
    .subscribe(onNext: {
    print($0)
})
    .disposed(by: disposeBag)

// "๋ฌธ์ฌ๋์๊ฐ"์ด๋ผ๋ ๋ค๋ฅธ ์ต์ ์ ๋ธ์ด onNext๋ฐฉ์ถํ๊ธฐ ์ ๊น์ง๋ Skip!

์๋.onNext("โบ๏ธ")
์๋.onNext("โบ๏ธ")
๋ฌธ์ฌ๋์๊ฐ.onNext("๋ก")
์๋.onNext("๐ฅธ")

print("----take----")
// ๋ช๋ฒ์งธ ์ธ๋ฑ์ค๊น์ง ํ ์ง !(Skip์ ๋ฐ๋๊ฐ๋)
Observable.of("๊ธ๋ฉ๋ฌ", "์๋ฉ๋ฌ", "๋๋ฉ๋ฌ", "4๋ฑ", "5๋ฑ")
    .take(3)
    .subscribe(onNext: {
    print($0)
})
    .disposed(by: disposeBag)

print("----takeWhile----")
// ํด๋น element์ด์ ๊น์ง๋ง ๋ฐฉ์ถ(SkipWhile์ ๋ฐ๋๊ฐ๋)
Observable.of("๊ธ๋ฉ๋ฌ", "์๋ฉ๋ฌ", "๋๋ฉ๋ฌ", "4๋ฑ", "5๋ฑ")
    .take(while: {
    $0 != "๋๋ฉ๋ฌ"
}) // ๋๋ฉ๋ฌ ์ด์ ๊น์ง๋ง ๋ฐฉ์ถ
.subscribe(onNext: {
    print($0)
})
    .disposed(by: disposeBag)

print("----enumerated----")
// 3 ๋ฏธ๋ง์ ์ธ๋ฑ์ค๊น์ง, index & element๋ฅผ ๋ฐฉ์ถ !
Observable.of("๊ธ๋ฉ๋ฌ", "์๋ฉ๋ฌ", "๋๋ฉ๋ฌ", "4๋ฑ", "5๋ฑ")
    .enumerated()
    .takeWhile {
    $0.index < 3
}
    .subscribe(onNext: {
    print($0)
})
    .disposed(by: disposeBag)

print("----takeUntil----")
let ์๊ฐ์ ์ฒญ = PublishSubject<String>()
let ์ ์ฒญ๋ง๊ฐ = PublishSubject<String>()

์๊ฐ์ ์ฒญ
    .take(until: ์ ์ฒญ๋ง๊ฐ) // Trigger๊ฐ ๋๊ธฐ '์ด ์ '๊น์ง์ ์ด๋ฒคํธ๋ง ๋ฐฉ์ถ
.subscribe(onNext: {
    print($0)
})
    .disposed(by: disposeBag)

์๊ฐ์ ์ฒญ.onNext("๐")
์๊ฐ์ ์ฒญ.onNext("๐๐พโโ๏ธ")

์ ์ฒญ๋ง๊ฐ.onNext("์ ์ฒญ์ด ๋ง๊ฐ๋์์ต๋๋ค.")
์๊ฐ์ ์ฒญ.onNext("๐โโ๏ธ")

print("----distinctUntilChanged----")
// ๋ฐ๋ณต๋๋ element๋ ํ๋๋ก ์์ถํด์ฃผ๋ Operator
Observable.of("์ ๋", "์ ๋", "์ต๋ฌด์", "์ต๋ฌด์", "์๋๋ค", "์ ๋", "์ ๋", "์ต๋ฌด์", "์ต๋ฌด์","์ผ๊น์?","์ผ๊น์?")
    .distinctUntilChanged()
    .subscribe(onNext: {
        print($0)
    })
    .disposed(by: disposeBag)
