import RxSwift

let disposeBag = DisposeBag()

enum TraitsError: Error {
    case signle
    case maybe
    case completable
}

print("----Single 1----")
Single<String>.just("Check")
    .subscribe(
    onSuccess: {
        print($0)
    }, onFailure: {
        print("error : \($0)")
    }, onDisposed: {
        print("disposed")
    })
    .disposed(by: disposeBag)

print("----Single 2----")
Observable<String>.create({ observer -> Disposable in
    observer.onError(TraitsError.signle)
    return Disposables.create()
})
    .asSingle() // single처럼 쓸 수 있다 !
.subscribe(
    onSuccess: {
        print($0)
    }, onFailure: {
        print("error : \($0.localizedDescription)")
    }, onDisposed: {
        print("disposed")
    })
    .disposed(by: disposeBag)

print("----Single 3----")
enum JSONError: Error {
    case decodingError
}

struct SomeJson: Decodable {
    let name: String
}

let json1 = """
{"name": "park"}
"""

let json2 = """
{"my_name": "lee"}
"""

// json1 -> SomeJson에 Decoding -> 성공 or 실패
// 이거를 Single 시퀀스로 이용

//Single 시퀀스를 만드는 함수
func decode(json: String) -> Single<SomeJson> {
    Single<SomeJson>.create { observe -> Disposable in
        guard let data = json.data(using: .utf8),
            let json = try? JSONDecoder().decode(SomeJson.self, from: data) else {
            //MARK: 실패 시 옵저버에 failure라는 이벤트를 담아서 전달해 줘!
            observe(.failure(JSONError.decodingError))
            return Disposables.create()
        }
        //MARK: 성공 시 옵저버에 success라는 이벤트를 담아서 전달해 줘!
        observe(.success(json))
        return Disposables.create()
    }
}

decode(json: json1)
    .subscribe {
    switch $0 {
    case .success(let json):
        print(json.name)
    case .failure(let error):
        print(error)
    }
}
    .disposed(by: disposeBag)

print("----Maybe 1----")
Maybe<String>.just("Check")
    .subscribe(onSuccess: {
    print($0)
}, onError: {
        print($0)
    }, onCompleted: {
        print("Completed")
        //MARK: Single과의 차이점
    }, onDisposed: {
        print("Disposed")
    })
    .disposed(by: disposeBag)

print("----Maybe 2----")
//MARK: option + 커서 타입 체크 가능
Observable<String>.create { obsereve -> Disposable in
    obsereve.onError(TraitsError.maybe)
    return Disposables.create()
}
    .asMaybe()
    .subscribe(
    onSuccess: {
        print($0)
    }, onError: {
        print($0.localizedDescription)
    }, onCompleted: {
        print("Completed")
        //MARK: Single과의 차이점
    }, onDisposed: {
        print("Disposed")
    })
    .disposed(by: disposeBag)

print("----Completable 1----")
Completable.create { observer -> Disposable in
    observer(.error(TraitsError.completable))
    return Disposables.create()
}
    .subscribe(
    onCompleted: {
        print("completed")
    }, onError: {
        print("error : \($0)")
    }, onDisposed: {
        print("disposed")
    })
    .disposed(by: disposeBag)

print("----Completable 2----")
Completable.create { observer -> Disposable in
    observer(.completed)
    return Disposables.create()
}
    .subscribe(
    onCompleted: {
        print("completed")
    }, onError: {
        print("error : \($0)")
    }, onDisposed: {
        print("disposed")
    })
    .disposed(by: disposeBag)
 
