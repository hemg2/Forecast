//
//  LocationManager.swift
//  Forecast
//
//  Created by 1 on 2022/08/24.
//

import Foundation
import CoreLocation  //위치서비스 구현할때 필수

class LocationManager: NSObject {
    static let shared = LocationManager()
    private override init() {
        manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyThreeKilometers  //3km 메소드
        
        
        super.init()
        
        manager.delegate = self
        
    }
    
    let manager: CLLocationManager
    
    //파싱된 주소를 저장할곳
    var currentLocationTitle: String? {
        //프로퍼티 옵저버 추가 좌푤르담음 딕셔너리 추가
        didSet {
            var userInfo = [AnyHashable: Any]()
            if let location = currentLocation {
                userInfo["location"] = location
            }
            
            NotificationCenter.default.post(name: Self.currentLocationDidUpdate, object: nil, userInfo: userInfo)
        }
    }
    var currentLocation: CLLocation?
    
    //새로운 노티피케이션을 추가한다.
    static let currentLocationDidUpdate = Notification.Name(rawValue: "currentLocationDidUpdate")
    
    
    //외부에서 호출하는 메소드 추가
    func updateLocation() {
        let status: CLAuthorizationStatus
        
        if #available(iOS 14.0, *) {
            status = manager.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }
        switch status {
        case .notDetermined:
            requestAuthorization() // 허가 안됬으면 허가 요청하기
        case .authorizedAlways, .authorizedWhenInUse:
            requestCurrentLocation()
        case .denied, .restricted:
            print("not available")
        default:
            print("unknown")
        }
    }
    
}

extension LocationManager: CLLocationManagerDelegate {
    //사용허가 요청 , 현재위치 요청 메소드
    private func requestAuthorization() {
        //권한을 요청하는코드 매니저가 호출하는 코드
//        manager.requestAlwaysAuthorization()// 백그라운드에서도 위치 가능
        manager.requestWhenInUseAuthorization() //이건 그냥 킬때만.
    }
    private func requestCurrentLocation() {
//        manager.startUpdatingLocation() //위치정보를 지속적 반복적으로 받아야한다면 이 코드
        manager.requestLocation() // 위치정보 한번 이면 될때 날씨니깐 한번이면된다.
        
    }
    
    private func updateAddress(from location: CLLocation) {
        //지오코딩 주소를 좌표로 바꾸는걸 포워드 지오코딩/ 걍 지오코딩     좌표를 주소로 바꾸는걸 리버스지오코딩
        //리버스 지오코딩 구현
        let geocoder = CLGeocoder()  //지오코더를 만듬
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            if let error = error {
                print(error)   //에러가 있다면 여기다
                self?.currentLocationTitle = "Unknown"
                return
            }
            
            //배열이 없다면 첫번째 파라미터로 간다 그가 여기다
            if let placemark = placemarks?.first {
                if let gu = placemark.locality, let dong = placemark.subLocality {
                    self?.currentLocationTitle = "\(gu) \(dong)"
                } else {
                    self?.currentLocationTitle = placemark.name ?? "Unknown"
                }
            }
            
            print(self?.currentLocationTitle)
        }
    }
    
    
    
    
    //허가 상태가 바뀌면 호출되는 메소드
    @available(iOS 14.0, *)
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            requestCurrentLocation()
        case .notDetermined, .denied, .restricted:
            print("not available")
        default:
            print("unknown")
        }
    }
    // ios 14 이전버전 호출 메소드
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            requestCurrentLocation()
        case .notDetermined, .denied, .restricted:
            print("not available")
        default:
            print("unknown")
        }
    }
    
    //새로운 위치정보가 전달되면 반복적으로 전달된다. //지도같은거네?
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print(locations.last)
        
        if let location = locations.last {
            currentLocation = location
            updateAddress(from: location)
        }
    }
    
    //에러가발생하면 호출
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}


