extension UpcomingMoviesPresentationMode {
    var cellIdentifier: String {
        switch self {
        case .preview:
            return UpcomingMoviePreviewCollectionViewCell.dequeueIdentifier
        case .detail:
            return UpcomingMovieExpandedCollectionViewCell.dequeueIdentifier
        }
    }
}
