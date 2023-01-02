import Foundation
import common
import KMPNativeCoroutinesAsync

@MainActor
class CityBikesViewModel: ObservableObject {
    @Published var stationList = [Station]()
    @Published var networkList = [Network]()
    
    private var fetchStationsTask: Task<(), Never>? = nil
    
    private let repository: CityBikesRepository
    init(repository: CityBikesRepository) {
        self.repository = repository
    }
 
    func fetchNetworks() {
        Task {
            let result = await asyncResult(for: repository.fetchNetworkListNative())
            if case let .success(networkList) = result {
                self.networkList = networkList
            }
        }
    }
    
    
    func startObservingBikeShareInfo(network: String) {
        
        fetchStationsTask = Task {
            do {
                let stream = asyncStream(for: repository.pollNetworkUpdatesNative(network: network))
                for try await data in stream {
                    self.stationList = data
                }
            } catch {
                print("Failed with error: \(error)")
            }
        }
    }
    
    func stopObservingBikeShareInfo() {
        fetchStationsTask?.cancel()
    }
}

