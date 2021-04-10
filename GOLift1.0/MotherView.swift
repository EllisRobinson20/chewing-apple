import SwiftUI

struct MotherView: View {
    
    @EnvironmentObject var viewRouter: ViewRouter
    let persistenceContainer = PersistenceController.shared
    
    var body: some View {
        switch viewRouter.currentPage {
        case .page1:
            BodyMapView()
                .environment(\.managedObjectContext, persistenceContainer.container.viewContext)
                .environmentObject(viewRouter)
        case .page2:
            ContentView()
                .transition(.scale)
                .environment(\.managedObjectContext, persistenceContainer.container.viewContext)
                .environmentObject(viewRouter)
        }
    }
    
}

