//
//  WeatherDataSource.swift
//  Forecast
//
//  Created by 1 on 2022/08/24.
//

import Foundation
import CoreLocation


class WeatherDataSource {
    static let shared = WeatherDataSource()
    private init() {
        //로케이션 매니저가 전달하는 노티피케이션에대한 옵저버를 추가하고 전달되면 api을 요청한다
        NotificationCenter.default.addObserver(forName: LocationManager.currentLocationDidUpdate, object: nil, queue: .main) { (noti) in
            
            if let location = noti.userInfo?["location"] as? CLLocation {
                self.fetch(location: location) {
                    //밑에있는 날씨 노티 캐스팅
                    NotificationCenter.default.post(name: Self.weatherInfoDidUpdate, object: nil)
                }
            }
        }
    }
    //노티피케이션 하나더 추가 날씨 정보가 업데이트 되었단 노티
    static let weatherInfoDidUpdate = Notification.Name(rawValue: "weatherInfoDidUpdate")
    
    
    var summary: CurrenWeather? // 현재 날씨
    var forecastList = [ForecastData]()//예보 데이터  // 모델 파일에 있는 부분
    let apiQueue = DispatchQueue(label: "ApiQueue", attributes: .concurrent)// api 사용할 디스패치큐 저장
    
    let group = DispatchGroup()
    
    func fetch(location: CLLocation, completion: @escaping () -> ()) {
        group.enter()
        apiQueue.async {
            self.fetchCurrentWeather(locatoin: location) { (result) in
                switch result {
                case .success(let data):
                    self.summary = data
                default:
                    self.summary = nil
                }
            self.group.leave()
            }
        }
        group .enter()
        apiQueue.async {
            self.fetchForecast(locatoin: location) { (result) in
                switch result {
                case .success(let data):
                    self.forecastList = data.list.map {
                        let dt = Date(timeIntervalSince1970: TimeInterval($0.dt))
                        let icon = $0.weather.first?.icon ?? ""
                        let weather = $0.weather.first?.description ?? "알 수 없음"
                        let temperature = $0.main.temp
                        
                        return ForecastData(date: dt, icon: icon, weather: weather, temperature: temperature)
                    }
                default:
                    self.forecastList = []
                }
            self.group.leave()
            }
            }
        group.notify(queue: .main) {
            completion()
        }
        }
    }

extension WeatherDataSource {
    private func fetch<ParsingType: Codable>(urlStr: String, completion: @escaping(Result<ParsingType, Error>) -> ()) {
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
    private func fetchCurrentWeather(cityName: String, completion: @escaping (Result<CurrenWeather, Error>) -> ()) {
        let urlStr = "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&appid=\(apiKey)&units=metric&lang=kr"
        
        fetch(urlStr: urlStr, completion: completion)
    }

    private func fetchCurrentWeather(cityId: Int, completion: @escaping (Result<CurrenWeather, Error>) -> ()) {
        let urlStr = "https://api.openweathermap.org/data/2.5/weather?id=\(cityId)&appid=\(apiKey)&units=metric&lang=kr"
        
        fetch(urlStr: urlStr, completion: completion)
    }
    private func fetchCurrentWeather(locatoin: CLLocation, completion: @escaping (Result<CurrenWeather, Error>) -> ()) {
        let urlStr = "https://api.openweathermap.org/data/2.5/weather?lat=\(locatoin.coordinate.latitude)&lon=\(locatoin.coordinate.longitude)&appid=\(apiKey)&units=metric&lang=kr"
        
        fetch(urlStr: urlStr, completion: completion)
    }
}

extension WeatherDataSource {
    private func fetchForecast(cityName: String, completion: @escaping (Result<Forecast, Error>) -> ()) {
        let urlStr = "https://api.openweathermap.org/data/2.5/forecast?q=\(cityName)&appid=\(apiKey)&units=metric&lang=kr"
        
        fetch(urlStr: urlStr, completion: completion)
    }

    private func fetchForecast(cityId: Int, completion: @escaping (Result<Forecast, Error>) -> ()) {
        let urlStr = "https://api.openweathermap.org/data/2.5/forecast?id=\(cityId)&appid=\(apiKey)&units=metric&lang=kr"
        
        fetch(urlStr: urlStr, completion: completion)
    }
    private func fetchForecast(locatoin: CLLocation, completion: @escaping (Result<Forecast, Error>) -> ()) {
        let urlStr = "https://api.openweathermap.org/data/2.5/forecast?lat=\(locatoin.coordinate.latitude)&lon=\(locatoin.coordinate.longitude)&appid=\(apiKey)&units=metric&lang=kr"
        
        fetch(urlStr: urlStr, completion: completion)
    }
}
