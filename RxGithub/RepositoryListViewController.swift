//
//  RepositoryListViewController.swift
//  GitHubRepositoryApp
//
//  Created by Bo-Young PARK on 2021/08/24.
//

import UIKit
import RxSwift
import RxCocoa

class RepositoryListViewController: UITableViewController {
    private let organization = "KW-My-Sheet"
    private let repositories = BehaviorSubject<[Repository]>(value: []) // 초기 선언이므로 빈 배열 !
    private let disposeBag = DisposeBag()
    //    private let repositories = [Repository] // Swift를 이용한 과거방식
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = organization + " Repositories"

        self.refreshControl = UIRefreshControl()
        let refreshControl = self.refreshControl!
        refreshControl.backgroundColor = .white
        refreshControl.tintColor = .darkGray
        refreshControl.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)

        tableView.register(RepositoryListCell.self, forCellReuseIdentifier: "RepositoryListCell")
        tableView.rowHeight = 140
    }

    @objc func refresh() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            self.fetchRepositories(of: self.organization)
        } // UI 안쓰니까 .global 사용 (Rx - Binding으로 처리가능)
    }

    //MARK: 각각의 Operator에 요소들을 심어놓을 수 있음 -> 걸러질 때 마다 비동기 프로그래밍이 가능 !
    func fetchRepositories(of organization: String) {
        Observable.from([organization]) // 배열만 이용할 수 있으므로
            .map { organization -> URL in
                
                print(" * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ")
                print("organization: \(organization)")
                print(" * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ")
                
            return URL(string: "https://api.github.com/orgs/\(organization)/repos")!
            } // String타입의 organization을 받아서 URL 타입으로 리턴하겠다 !
            .map { url -> URLRequest in
                
                print(" * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ")
                print("url: \(url)")
                print(" * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ")

            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            return request
            } // URL타입의 url을 받아서 URLRequest 타입으로 리턴하겠다!
            .flatMap { request -> Observable<(response: HTTPURLResponse, data: Data)> in
                
                print(" * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ")
                print("request: \(request)")
                print(" * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ")
                
            return URLSession.shared.rx.response(request: request)
            } // Tuple의 형태를 띄는 Observable 시퀀스로 반환
            .filter { response, _ in // Tuple 내에서 response만 받기 위해 _ 표시
                
                print(" * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ")
                print("response: \(response)")
                print(" * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ")
                
            return 200..<300 ~= response.statusCode // responds.statusCode가 해당범위에 해당하면 true
        }
            .map { _, data -> [[String: Any]] in
                
                print(" * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ")
                print("data: \(data)")
                print(" * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ")
                
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []),
                let result = json as? [[String: Any]] else {
                return []
            }
            return result
        }
            .filter { objects in // 빈 Array(연결 실패)는 안 받을래 !
                
                print(" * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ")
                print("objects: \(objects)")
                print(" * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ")
                
            return objects.count > 0
        }
            .map { objects in                 // compactMap: 1차원 배열에서 nil을 제거하고 옵셔널 바인딩
            return objects.compactMap { dic -> Repository? in
                
                print(" * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ")
                print("dic: \(dic)")
                print(" * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ")
                
                guard let id = dic["id"] as? Int,
                    let name = dic["name"] as? String,
                    let description = dic["description"] as? String,
                    let stargazersCount = dic["stargazers_count"] as? Int,
                    let language = dic["language"] as? String else {
                    return nil
                }

                return Repository(id: id, name: name, description: description, stargazersCount: stargazersCount, language: language)
            }
        } //MARK: [[dic_1],[dic_2],[dic_3]]이 compactMap을 통해 [dic_1] -> Repository로 각각 리턴
            .subscribe(onNext: { [weak self] newRepositories in
                // 위에서 리턴된 3개를 각각 구독 -> 바로 이벤트 생성하여 BehaviorSubject로 하여금 방출하도록.
                print(" * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ")
                print("newRepositories: \(newRepositories)")
                print(" * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * ")
                
            self?.repositories.onNext(newRepositories) // BehaviorSubject에 이벤트 발생

            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.refreshControl?.endRefreshing()
            }
        })
            .disposed(by: disposeBag)
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

