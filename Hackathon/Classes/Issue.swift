class Issue {
    
    var name : String?
    var latitude : Double?
    var longitude : Double?
    var mediaURL : String?
    var description : String?
    var category : String?
    var mostViewed : Bool?
    var concerns : Int?
    var email : String?
    var media_type: String?
    
    init(
        name: String?,
        latitude: Double?,
        longitude: Double?,
        mediaURL: String?,
        description: String?,
        category: String?,
        mostViewed: Bool?,
        concerns: Int?,
        email: String?,
        media_type: String?
        )
    {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.mediaURL = mediaURL
        self.description = description
        self.category = category
        self.mostViewed = mostViewed
        self.concerns = concerns
        self.email = email
        self.media_type = media_type
    }
}


