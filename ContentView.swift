import SwiftUI
import SwiftData

// MARK: - Trip Model
@Model
class Trip {
    var id: UUID
    var destination: String
    var departureDate: Date
    var seatClass: String
    var price: Double
    var status: String
    
    init(destination: String, departureDate: Date, seatClass: String, price: Double, status: String = "Upcoming") {
        self.id = UUID()
        self.destination = destination
        self.departureDate = departureDate
        self.seatClass = seatClass
        self.price = price
        self.status = status
    }
}

// MARK: - Trip Booking View
struct TripBookingView: View {
    @Environment(\.modelContext) private var context
    @State private var selectedDestination = "Lunar Base Alpha"
    @State private var departureDate = Date()
    @State private var selectedSeatClass = "Economy Shuttle"
    @State private var selectedImage = "package1"  // Default to Economy Shuttle
    
    let destinations = ["Lunar Base Alpha", "Mars Colony One", "Orbital Resort 5"]
    let seatClasses = ["Economy Shuttle", "Luxury Cabin", "VIP Zero-Gravity"]
    let images = ["package1", "package2", "package3"]  // Corresponding image names
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 10) {
                    Image(selectedImage)  // Dynamically change image based on selected seat class
                        .resizable()
                        .scaledToFit()
                        .frame(height: 250)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .shadow(radius: 10)
                        .padding(.top, 20)
                    
                    // Departure Date Picker with Space-style design
                    DatePicker("Departure", selection: $departureDate, displayedComponents: .date)
                        .datePickerStyle(.automatic)
                    
                        .frame(maxWidth: .infinity)
                       .padding(.horizontal,10)
                       .background(Color.primary.opacity(0.2))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    
                    // Destination Picker with Segmented style
                    Picker("Destination", selection: $selectedDestination) {
                        ForEach(destinations, id: \.self) { destination in
                            Text(destination)
                                .foregroundColor(.white)

                        }
                    }
                    .frame(maxWidth: .infinity)

                    
                    .pickerStyle(.automatic)
                    .padding(.horizontal,5)
                    .background(Color.primary.opacity(0.2))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    
                    // Seat Class Picker with Segmented style
                    Picker("Seat Class", selection: $selectedSeatClass) {
                        ForEach(seatClasses, id: \.self) { seatClass in
                            Text(seatClass)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal,5)
                    .background(Color.primary.opacity(0.2))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .onChange(of: selectedSeatClass) { newValue in
                        updateImage(for: newValue)
                    }
                    
                    // Confirm Booking Button
                    Button(action: bookTrip) {
                        Text("Confirm Booking")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color.mint, Color.purple]), startPoint: .top, endPoint: .bottom)
                            )
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .shadow(radius: 10)
                           // .padding(.top, 30)
                    }
                   // .padding(.horizontal, 20)
                    .padding()
                }
                .padding(.horizontal, 20)
                .background(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.8), Color.blue.opacity(0.7)]), startPoint: .top, endPoint: .bottom))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding()
            }
            .navigationTitle("Book Your Trip")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    func bookTrip() {
        let price = calculatePrice()
        let newTrip = Trip(destination: selectedDestination, departureDate: departureDate, seatClass: selectedSeatClass, price: price)
        context.insert(newTrip)
    }
    
    func calculatePrice() -> Double {
        switch selectedSeatClass {
        case "Economy Shuttle": return 50000
        case "Luxury Cabin": return 150000
        case "VIP Zero-Gravity": return 300000
        default: return 0
        }
    }
    
    // Update image based on seat class
    func updateImage(for seatClass: String) {
        switch seatClass {
        case "Economy Shuttle":
            selectedImage = "package1"
        case "Luxury Cabin":
            selectedImage = "package2"
        case "VIP Zero-Gravity":
            selectedImage = "package3"
        default:
            selectedImage = "package1"
        }
    }
}

// MARK: - Pricing & Packages View with Hero View
struct PricingPackagesView: View {
    @Namespace private var namespace  // Namespace for matchedGeometryEffect
    @State private var selectedPackage: Package? = nil  // Track the selected package for hero view
    
    // Packages data
    let packages = [
        Package(title: "Economy Shuttle", price: 50000, description: "Affordable space travel with modern amenities.", imageName: "package1"),
        Package(title: "Luxury Cabin", price: 150000, description: "Elegant, spacious cabins with premium services.", imageName: "package2"),
        Package(title: "VIP Zero-Gravity", price: 300000, description: "Experience the luxury of zero-gravity with personalized services.", imageName: "package3")
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                if let selectedPackage = selectedPackage {
                    // Hero View (expand on card tap)
                    PackageHeroView(package: selectedPackage, namespace: namespace, onDismiss: { self.selectedPackage = nil })
                } else {
                    // List of Packages
                    ScrollView {
                        ForEach(packages, id: \.title) { package in
                            PricingCardView(package: package, namespace: namespace)
                                .onTapGesture {
                                    self.selectedPackage = package  // Show the hero view on tap
                                }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Packages")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Package Model
struct Package {
    var title: String
    var price: Double
    var description: String
    var imageName: String
}

// MARK: - Pricing Card View (List)
struct PricingCardView: View {
    let package: Package
    var namespace: Namespace.ID
    
    var body: some View {
        VStack {
            Image(package.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .matchedGeometryEffect(id: package.title, in: namespace) // Hero transition effect
            
            Text(package.title).font(.title2).bold()
            Text("$\(package.price, specifier: "%.0f")").font(.title).foregroundColor(.primary)
            Text(package.description).font(.subheadline).multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.blue.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        //.shadow(radius: 5)
    }
}

// MARK: - Package Hero View (Expanded View)
struct PackageHeroView: View {
    let package: Package
    var namespace: Namespace.ID
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 5) {
            // Image Section with refined styling and shadow
            Image(package.imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .shadow(radius: 5)
            
            // Title
            Text(package.title)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(nil) // Allow for unlimited lines, no truncation
                .fixedSize(horizontal: false, vertical: true) 
                .padding(.horizontal)
            
            // Price
            Text("$\(package.price, specifier: "%.0f")")
                .font(.system(size: 32, weight: .semibold, design: .rounded))
                .foregroundColor(.green)
                .padding(.horizontal)
            
            // Description with proper text expansion handling
            Text(package.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(nil) // Allow for unlimited lines, no truncation
                .fixedSize(horizontal: false, vertical: true) // Allow vertical expansion
                .padding(.horizontal)
                .layoutPriority(1) // Ensure it gets the remaining space
            
            // Close Button
            Button(action: {
                onDismiss()
            }) {
                Text("Close")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .top, endPoint: .bottom)
                    )
                    .foregroundColor(.white)
                    .clipShape(Capsule())
                    .shadow(radius: 5)
                    .padding(.top, 20)
            }
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.9), Color.blue.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
        )
        .cornerRadius(30)
        .shadow(radius: 20)
        .padding(.horizontal)
    }
}

struct PricingPackagesView_Previews: PreviewProvider {
    static var previews: some View {
        PricingPackagesView()
    }
}

struct PricingCard: View {
    let title: String
    let price: Int
    let description: String
    let imageName: String
    
    var body: some View {
        VStack(spacing: 15) {
            // Image Section
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(height: 180)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 10)
            
            // Title
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Price Section
            Text("$\(price, specifier: "%.0f")")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.green)
            
            // Description
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Button (Optional)
            Button(action: {
                // Add action for the button here
            }) {
                Text("Book Now")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.primary)
                    .clipShape(Capsule())
                    .padding(.top, 10)
            }
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 15)
    }
}

// MARK: - User Dashboard View
struct UserDashboardView: View {
    @Environment(\.modelContext) private var context
    @Query private var trips: [Trip]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(trips) { trip in
                    VStack(alignment: .leading) {
                        Image(imageForSeatClass(trip.seatClass))
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth:.infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .shadow(radius: 5)
                        
                        Text(trip.destination).font(.headline)
                        Text("Departure: \(trip.departureDate.formatted(.dateTime.month().day().year()))").font(.subheadline)
                        Text("Seat: \(trip.seatClass)").font(.subheadline)
                        Text("Price: $\(trip.price, specifier: "%.2f")").font(.subheadline)
                    }
                    .padding()
                }
                .onDelete(perform: deleteTrip)
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Your Trips")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    func deleteTrip(at offsets: IndexSet) {
        for index in offsets {
            context.delete(trips[index])
        }
    }
    
    func imageForSeatClass(_ seatClass: String) -> String {
        switch seatClass {
        case "Economy Shuttle": return "package1"
        case "Luxury Cabin": return "package2"
        case "VIP Zero-Gravity": return "package3"
        default: return "package1"
        }
    }
}

// MARK: - AI Travel Tips View
struct TravelTipsView: View {
    let tips = [
        ("Pack light, but don’t forget space-friendly toiletries!", "toilet"),
        ("Adjust your sleep cycle before launch.", "sleep"),
        ("Stay hydrated—dehydration is common in space!", "hydrate"),
        ("Practice using touchscreen controls in gloves.", "gloves")
    ]
    
    @State private var currentTipIndex = 1
    
    var body: some View {
        NavigationStack {
            VStack {
                // Display the corresponding image for each tip
                Image(tips[currentTipIndex].1)  // Image associated with the current tip
                    .resizable()
                    .scaledToFit()

                    .frame(maxWidth:.infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(radius: 10)
                    .padding(.top, 20)
                
                // Display the current tip text
                Text(tips[currentTipIndex].0)  // Tip text
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding()
                
                // Next Tip Button
                Button("Next Tip") {
                    withAnimation {
                        currentTipIndex = (currentTipIndex + 1) % tips.count
                    }
                }
                .frame(maxWidth:.infinity)

                .padding(.horizontal)
                .padding()
                

                .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .top, endPoint: .bottom))
                .foregroundColor(.white)
                .clipShape(Capsule())
                .shadow(radius: 10)
                .padding(.top, 20)
            }
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: [Color.black.opacity(0.7), Color.blue.opacity(0.5)]), startPoint: .top, endPoint: .bottom))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding()
            .navigationTitle("AI Travel Tips")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}



// MARK: - Main App Navigation
struct MainView: View {
    var body: some View {
        TabView {
            TripBookingView()
                .tabItem { Label("Book Trip", systemImage: "airplane.departure") }
            
            PricingPackagesView()
                .tabItem { Label("Pricing", systemImage: "dollarsign.circle") }
            
            UserDashboardView()
                .tabItem { Label("Dashboard", systemImage: "person.crop.circle") }
            
            TravelTipsView()
                .tabItem { Label("AI Tips", systemImage: "lightbulb.fill") }
        }
        .accentColor(.purple)
    }
}

// MARK: - App Entry Point
@main
struct SpaceTravelBookingApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .modelContainer(for: Trip.self)
        }
    }
}
