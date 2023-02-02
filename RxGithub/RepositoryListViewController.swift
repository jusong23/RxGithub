//
//  RepositoryListViewController.swift
//  GitHubRepositoryApp
//
//  Created by Bo-Young PARK on 2021/08/24.
//

import UIKit
import RxSwift
import RxCocoa

public class SimpleError: Error {
    public init() { }
}
// return Observable.error(SimpleError())
// throw SimpleError()

class RepositoryListViewController: UITableViewController {
    private let organization = "KW-My-Sheet"
    private let repositories = BehaviorSubject<[Repository]>(value: []) // 초기 선언이므로 빈 배열 !
    private let disposeBag = DisposeBag()
    //    private let repositories = [Repository] // Swift를 이용한 과거방식

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControlConfiguration()
        self.tableViewConfiguration()
    }
    
    func refreshControlConfiguration(){
        self.refreshControl = UIRefreshControl()
        let refreshControl = self.refreshControl!
        refreshControl.backgroundColor = .white
        refreshControl.tintColor = .darkGray
        refreshControl.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
    }

    func tableViewConfiguration(){
        tableView.register(RepositoryListCell.self, forCellReuseIdentifier: "RepositoryListCell")
        tableView.rowHeight = 140
    }
    
    @objc func refresh() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            self.fetchRepositories(of: self.organization)
        } // UI작업은 Binding으로도 처리가능
    }

    //MARK: 각각의 Operator에 요소들을 심어놓을 수 있음 -> 걸러질 때 마다 비동기 프로그래밍이 가능 !
    func fetchRepositories(of organization: String) {
        Observable.from([organization]) // 배열만 이용할 수 있으므로
        .map { organization -> URL in //MARK: 타입 변경할 때도 map이 유용하다.
            return URL(string: "https://api.github.com/orgs/\(organization)/repos")!
        } // String타입의 organization을 받아서 URL 타입으로 리턴하겠다 !
        .map { url -> URLRequest in
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            return request
        } // URL타입의 url을 받아서 URLRequest 타입으로 리턴하겠다!
        .flatMap { request -> Observable<(response: HTTPURLResponse, data: Data)> in
            return URLSession.shared.rx.response(request: request)
        } // Tuple의 형태를 띄는 Observable 시퀀스로 반환
        .filter { response, _ in // Tuple 내에서 response만 받기 위해 _ 표시
            return 200..<300 ~= response.statusCode // responds.statusCode가 해당범위에 해당하면 true
        }
        .map { _, data -> [[String: Any]] in
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
                let result = json as? [[String: Any]] else {
                return []
            }
            throw SimpleError()
            return result
        }
        .map { objects in // compactMap: 1차원 배열에서 nil을 제거하고 옵셔널 바인딩
            return objects.compactMap { dic -> Repository? in
                guard let id = dic["id"] as? Int,
                    let name = dic["name"] as? String,
                    let description = dic["description"] as? String,
                    let stargazersCount = dic["stargazers_count"] as? Int,
                    let language = dic["language"] as? String else {
                    return nil
                }
                return Repository(id: id, name: name, description: description, stargazersCount: stargazersCount, language: language)
            }
        }
        //MARK: [[dic_1],[dic_2],[dic_3]]이 compactMap을 통해 [dic_1] -> Repository로 각각 리턴
        //MARK: - 이 라인을 기준으로 global/main 구분 -> DispatchQueue를 쓰지않고 동시에 main 쓰레드에서 UI를 띄울수 있다.
        .subscribe(on: ConcurrentDispatchQueueScheduler(queue: .global()))
        .observe(on: MainScheduler.instance)
        .subscribe { event in //MARK: 에러처리에 용이한 subscribe 트릭
            switch event {
            case .next(let newRepositories):
                self.repositories.onNext(newRepositories) // BehaviorSubject에 이벤트 발생
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            case .error(let error):
                self.refreshControl?.endRefreshing()
                self.alertAction()
            case .completed:
                print("completed")
            }

        }
            .disposed(by: disposeBag)
    }

    func alertAction() {
        let optionMenu = UIAlertController(title: "에러", message: "네트워크 상태를 확인하세요.", preferredStyle: .alert)

        let Action = UIAlertAction(title: "확인", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("확인")
        })
        optionMenu.addAction(Action)
        self.present(optionMenu, animated: true, completion: nil)
    }


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        do {
            return try repositories.value().count
        } catch {
            return 0
        } // BehaviorSubject의 특징 이용하여 값만 가져오기(.count와 동일)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RepositoryListCell", for: indexPath) as? RepositoryListCell else { return UITableViewCell() }

        var currentRepo: Repository? {
            do {
                return try repositories.value()[indexPath.row]
            } catch {
                return nil
            }
        }

        cell.repository = currentRepo

        return cell
    }
}
