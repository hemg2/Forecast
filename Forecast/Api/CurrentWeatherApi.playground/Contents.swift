import UIKit
import CoreLocation //좌표?

struct CurrenWeather: Codable {
    let dt: Int
    
    struct Weather: Codable {
        let id : Int
        let main : String
        let description : String
        let icon : String
    }
    let weather: [Weather]
    
    struct Main: Codable {
        let temp : Double
        let temp_min : Double
        let temp_max : Double
    }
    let main : Main
}

enum ApiError : Error {
    case unknown
    case invalidUrl(String)
    case invalidResponse
    case failed(Int)
    case emptyData
}
func fetch<ParsingType: Codable>(urlStr: String, completion: @escaping(Result<ParsingType, Error>) -> ()) {
    guard let url = URL(string: urlStr) else {
//        fatalError("URL 생성 실패")  // 페이틀에러는 호출되면 크래쉬 된다 공부할떄만 사용
        completion(.failure(ApiError.invalidUrl(urlStr)))
        return
    }
    // 테스크를 만든 다음 항상 리줌을 호출해야한다.
    let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
        if let error = error {
            fatalError(error.localizedDescription)
            return
        }
        guard let httpResponse = response as? HTTPURLResponse else {
//            fatalError("invalid response")
            completion(.failure(ApiError.invalidResponse))
            return
        }
        guard httpResponse.statusCode == 200 else {
//            fatalError("failed code \(httpResponse.statusCode)")
            completion(.failure(ApiError.failed(httpResponse.statusCode)))
            return
        }
        guard let data = data else {
//            fatalError("empty data")
            completion(.failure(ApiError.emptyData))
            return
        }
        do {
            let decoder = JSONDecoder()     // 셀프를 꼭 붙여야한다.
            let data = try decoder.decode(ParsingType.self, from: data)
            completion(.success(data))
//            weather.weather.first?.description
//            weather.main.temp
        } catch {
            completion(.failure(error))
//            fatalError(error.localizedDescription)
        }
    }
    task.resume()  //호출하기.
}

func fetchCurrentWeather(cityName: String, completion: @escaping (Result<CurrenWeather, Error>) -> ()) {
    let urlStr = "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=aaa5700cbd82d1a09e738731002f97be&units=metric&lang=kr"
    
    fetch(urlStr: urlStr, completion: completion)
}

func fetchCurrentWeather(cityId: Int, completion: @escaping (Result<CurrenWeather, Error>) -> ()) {
    let urlStr = "https://api.openweathermap.org/data/2.5/weather?id=\(cityId)&appid=aaa5700cbd82d1a09e738731002f97be&units=metric&lang=kr"
    
    fetch(urlStr: urlStr, completion: completion)
}
func fetchCurrentWeather(locatoin: CLLocation, completion: @escaping (Result<CurrenWeather, Error>) -> ()) {
    let urlStr = "https://api.openweathermap.org/data/2.5/weather?lat=\(locatoin.coordinate.latitude)&lon=\(locatoin.coordinate.longitude)&appid=aaa5700cbd82d1a09e738731002f97be&units=metric&lang=kr"
    
    fetch(urlStr: urlStr, completion: completion)
}

let location = CLLocation(latitude: 37.498206, longitude: 127.02761)
fetchCurrentWeather(locatoin: location) { (result) in
    switch result {
    case .success(let weather):
        dump(weather)
    case .failure(let error):
        print(error)
    }
}


//fetchCurrentWeather(cityName: "seoul") { _ in }
//
//fetchCurrentWeather(cityId: 1835847) { (result) in
//    switch result {
//    case .success(let weather):
//        dump(weather)
//    case .failure(let error):
//        print(error)
//    }
//}

