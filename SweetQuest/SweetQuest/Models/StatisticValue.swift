struct StatisticValue: Codable {
    
    var gamesPlayed: Int
    var wins: Int
    var losses: Int
    
    var openedCollection: [CollectionItem]
    
    init(
        gamesPlayed: Int = 0,
        wins: Int = 0,
        losses: Int = 0,
        openedCollection: [CollectionItem] = []
    ) {
        self.gamesPlayed = gamesPlayed
        self.wins = wins
        self.losses = losses
        self.openedCollection = openedCollection
    }
}

enum CollectionItem: String, Codable, CaseIterable, Identifiable {
    var id: Self { self }
    case cherrySwirl
    case heartPop
    case berryStripes
    case goldenToffee
    case mintTruffle
    case rainbowSlice
    case sugarStar
    case miniCake
    case creamRoll
    case sweetStrawberry
    case pinkMacaron
    case gummyBear
    case berrySlice
    case candySpiral
    case blueTwist
    case colorRing
    
    var title: String {
        switch self {
        case .cherrySwirl: "Cherry Swirl"
        case .heartPop: "Heart Pop"
        case .berryStripes: "Berry Stripes"
        case .goldenToffee: "Golden Toffee"
        case .mintTruffle: "Mint Truffle"
        case .rainbowSlice: "Rainbow Slice"
        case .sugarStar: "Sugar Star"
        case .miniCake: "Mini Cake"
        case .creamRoll: "Cream Roll"
        case .sweetStrawberry: "Sweet Strawberry"
        case .pinkMacaron: "Pink Macaron"
        case .gummyBear: "Gummy Bear"
        case .berrySlice: "Berry Slice"
        case .candySpiral: "Candy Spiral"
        case .blueTwist: "Blue Twist"
        case .colorRing: "Color Ring"
        }
    }
    
    var description: String {
        switch self {
        case .cherrySwirl: "Creamy candy with a sweet cherry touch."
        case .heartPop: "A lovely pink lollipop full of sugary joy."
        case .berryStripes: "Strawberry coated in smooth striped chocolate."
        case .goldenToffee: "Soft caramel wrapped in sunny sweetness."
        case .mintTruffle: "Rich chocolate with cool mint cream."
        case .rainbowSlice: "Bright fruity layers in one cheerful candy."
        case .sugarStar: "Crunchy cookie sparkling with sugar."
        case .miniCake: "Tiny chocolate dessert with a berry on top."
        case .creamRoll: "Light pastry with a creamy chocolate center."
        case .sweetStrawberry: "Juicy berry-shaped gummy treat."
        case .pinkMacaron: "Delicate almond cookie with soft filling."
        case .gummyBear: "Cute chewy bear bursting with apple flavor."
        case .berrySlice: "Mini layered cake with strawberry glaze."
        case .candySpiral: "Classic swirled candy with creamy taste."
        case .blueTwist: "Shiny caramel with a hint of sea breeze."
        case .colorRing: "Fun chewy candy in bright fruity colors."
        }
    }
}
