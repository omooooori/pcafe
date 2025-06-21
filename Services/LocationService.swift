import Foundation
import CoreLocation
import Combine

class LocationService: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    
    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationError: LocationError?
    
    enum LocationError: Error, LocalizedError {
        case denied
        case restricted
        case unavailable
        case unknown
        
        var errorDescription: String? {
            switch self {
            case .denied:
                return "位置情報の使用が拒否されました。設定から許可してください。"
            case .restricted:
                return "位置情報の使用が制限されています。"
            case .unavailable:
                return "位置情報が利用できません。"
            case .unknown:
                return "位置情報の取得中にエラーが発生しました。"
            }
        }
    }
    
    override init() {
        super.init()
        setupLocationManager()
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // 10メートル移動したら更新
    }
    
    func requestLocationPermission() {
        switch authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            locationError = .denied
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        @unknown default:
            locationError = .unknown
        }
    }
    
    func startLocationUpdates() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            locationError = .denied
            return
        }
        
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationUpdates() {
        locationManager.stopUpdatingLocation()
    }
    
    func getCurrentLocation() -> AnyPublisher<CLLocation, LocationError> {
        guard let location = currentLocation else {
            return Fail(error: LocationError.unavailable)
                .eraseToAnyPublisher()
        }
        return Just(location)
            .setFailureType(to: LocationError.self)
            .eraseToAnyPublisher()
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        locationError = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .denied:
                locationError = .denied
            case .locationUnknown:
                locationError = .unavailable
            default:
                locationError = .unknown
            }
        } else {
            locationError = .unknown
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdates()
        case .denied, .restricted:
            locationError = .denied
        case .notDetermined:
            break
        @unknown default:
            locationError = .unknown
        }
    }
} 