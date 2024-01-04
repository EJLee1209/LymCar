//
//  MapViewRepresentable.swift
//  LymCar
//
//  Created by 이은재 on 12/19/23.
//

import SwiftUI
import MapKit

/// SwiftUI에서 UIkit을 사용하기 위해서 UIViewRepresentable 프로토콜을 구현하면, SwiftUI에서 UIView 사용이 가능하다.
/// 필수 메서드로는 makeUIView(context:) 와 updateUIView(_, context:) 가 있다.
/// makeUIView(context:)는 사용할 UIView를 생성하고, 초기화하는 메서드이고,
/// updateUIView(_, context:)는 UIView 업데이트가 필요할 때 호출되는 메서드이다.
/// 그 외 UIView의 복잡한 기능(Delegate)을 구현하기 위해서 Coordinator를 구현한다.
struct MapViewRepresentable: UIViewRepresentable {
    
    //MARK: - Properties
    @EnvironmentObject private var appData: AppData
    @ObservedObject var mapViewModel: MapView.ViewModel
    @Binding var mapState: MapState
    
    let mapView = MKMapView()
    let locationManager = LocationManager()
    
    /// UIView를 생성하고 초기화
    func makeUIView(context: Context) -> some UIView {
        mapView.delegate = context.coordinator
        mapView.isRotateEnabled = false
        mapView.showsUserLocation = true
        return mapView
    }
    
    /// UIView 업데이트가 필요할 때 호출
    func updateUIView(_ uiView: UIViewType, context: Context) {
        switch mapState {
        case .none:
            context.coordinator.clearMapViewAndRecenterOnUserLocation()
            guard let userLocationCoordinate = mapViewModel.userLocationCoordinate else { return }
            let userLocation = CLLocation(
                latitude: userLocationCoordinate.latitude,
                longitude: userLocationCoordinate.longitude
            )
            context.coordinator.getAddress(from: userLocation)
        case .searchingForLocation:
            break
        case .locationSelected:
            guard let departurePlaceCoordinate = mapViewModel.departurePlaceCoordinate,
                  let destinationCoordinate = mapViewModel.destinationCoordinate else { return }
            
            mapView.removeAnnotations(mapView.annotations)
            context.coordinator.addAnnotation(withCoordinate: departurePlaceCoordinate)
            context.coordinator.addAnnotation(withCoordinate: destinationCoordinate)
            context.coordinator.configurePolyline(from: departurePlaceCoordinate, to: destinationCoordinate)
        }
    }
    
    func makeCoordinator() -> MapCoordinator {
        return MapCoordinator(parent: self)
    }
    
}

//MARK: - MapCoordinator
/// UIView의 Delegate 역할을 하는 Coordinator
/// UIKit -> SwiftUI로의 데이터 전달을 하는 기능 수행
extension MapViewRepresentable {
    class MapCoordinator: NSObject, MKMapViewDelegate {
        //MARK: - Properties
        let parent: MapViewRepresentable
        private var currentRegion: MKCoordinateRegion?
        
        
        //MARK: - LifeCycle
        init(parent: MapViewRepresentable) {
            self.parent = parent
            super.init()
        }
        
        //MARK: - MKMapViewDelegate
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            let coordinate = userLocation.coordinate
            let region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            currentRegion = region
            parent.mapViewModel.userLocationCoordinate = coordinate
            if parent.mapState != .locationSelected {
                parent.mapView.setRegion(region, animated: true)
                parent.mapViewModel.departurePlaceCoordinate = coordinate
            }
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let polyline = MKPolylineRenderer(overlay: overlay)
            polyline.strokeColor = .systemBlue
            polyline.lineWidth = 6
            return polyline
        }
        
        //MARK: - Helpers
        
        /// annotation을 추가하는 메서드
        func addAnnotation(withCoordinate coordinate: CLLocationCoordinate2D) {
            let anno = MKPointAnnotation()
            anno.coordinate = coordinate
            parent.mapView.addAnnotation(anno)
        }
        
        /// 내부적으로 getDestinationRoute 메서드를 호출하여 경로를 가져오고, mapView에 overlay를 등록하는 메서드
        func configurePolyline(
            from departurePlaceCoordinate: CLLocationCoordinate2D,
            to destinationCoordinate: CLLocationCoordinate2D
        ) {
            self.parent.mapView.removeOverlays(self.parent.mapView.overlays)
            
            getDestinationRoute(from: departurePlaceCoordinate, to: destinationCoordinate) { route in
                self.parent.mapView.addOverlay(route.polyline)
                let rect = self.parent.mapView.mapRectThatFits(
                    route.polyline.boundingMapRect,
                    edgePadding: .init(
                        top: 64,
                        left: 32,
                        bottom: 300,
                        right: 32
                    )
                )
                self.parent.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
            }
        }
        
        /// 출발지와 목적지의 경로를 가져오는 메서드
        func getDestinationRoute(
            from departurePlace: CLLocationCoordinate2D,
            to destination: CLLocationCoordinate2D,
            completion: @escaping(MKRoute) -> Void
        ) {
            let departPlaceMark = MKPlacemark(coordinate: departurePlace)
            let destPlaceMark = MKPlacemark(coordinate: destination)
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: departPlaceMark)
            request.destination = MKMapItem(placemark: destPlaceMark)
            let directions = MKDirections(request: request)
            
            directions.calculate { response, error in
                if let error = error {
                    print("DEBUG: Failed to get directions with error \(error.localizedDescription)")
                    return
                }
                
                guard let route = response?.routes.first else { return }
                completion(route)
            }
        }
        
        func clearMapViewAndRecenterOnUserLocation() {
            parent.mapView.removeAnnotations(parent.mapView.annotations)
            parent.mapView.removeOverlays(parent.mapView.overlays)
            
            guard let currentRegion = self.currentRegion else { return }
            parent.mapView.setRegion(currentRegion, animated: true)
        }
        
        func getAddress(from location: CLLocation) {
            let geocoder = CLGeocoder()
            let local = Locale(identifier: "Ko-kr")
            geocoder.reverseGeocodeLocation(location, preferredLocale: local) { placemarks, error in
                if let error = error {
                    print("DEBUG: Failed to reverse geocoding with error \(error.localizedDescription)")
                    return
                }
                guard let placemark = placemarks?.last else { return }
                var address: String = ""
                
                if let locality = placemark.locality {
                    address += locality + " "
                }
                if let name = placemark.name {
                    address += name
                }
                
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    if parent.mapViewModel.departurePlaceText != address {
                        parent.mapViewModel.departurePlaceText = address
                        
                        guard let userCoordinate = parent.mapViewModel.userLocationCoordinate else { return }
                        parent.appData.departureLocationCoordinate = userCoordinate
                        parent.appData.userLocationCoordinate = userCoordinate
                        parent.appData.departurePlaceName = address
                    }
                }
            }
        }
    }
}
