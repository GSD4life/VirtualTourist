# VirtualTourist - IOS Application built as part of Udacity's IOS Nanodegree program

The Virtual Tourist app downloads and stores images from Flickr. Users will be able to drop pins on a map, download pictures for the location, and save favorites to their device.

## Functionality:

The app first loads a mapView where the user can use the standard scroll and zoom features. Tapping and holding the map will drop a new pin. If a pin is tapped the app will transition to the Photo Album view using the coordinates of that pin.

The Photo Album view loads and attempts to download images from Flickr based on the latitude and longitude of the selected pin. If images are available, the view will show a mapView at the top and images below the map within a collectionView. Once the images are downloaded a newCollectionButton will become visible at the bottom of the page. Tapping the newCollectionButton will empty the collectionView and attempt to download a new set of images of Flickr.

Users are able to remove an image from the collectionView by first tapping an image, followed by tapping the newCollectionButton which now has the title "Remove Selected Picture". The remaining images should move to fill in the newly empty space.

If the selected pin does not have any images then the view will show a mapView at the top with a "no images" label below the map. The newCollectionButton will not be visible. 

All changes made in the Photo Album view are made persistent in Core Data.

Tapping the Ok button in the Photo Album view returns the user to the first view (mapView) of the app. If the user decides to  tap a pin which already has a set of images, the app will load the images from Core Data, instead of trying to download images from Flickr when transitioning to the Photo Album view.

TravelLocationsMapView 

<img width="221" alt="TravelLocationsMapView" src="https://user-images.githubusercontent.com/35928028/60674626-83591c80-9e48-11e9-8d52-0977c69c453e.png">

PhotoAlbumView 

<img width="222" alt="PhotoAlbumView" src="https://user-images.githubusercontent.com/35928028/60674895-2ad64f00-9e49-11e9-97fb-70c502a85b98.png">

### Installation:

1. git clone: https://github.com/GSD4life/VirtualTourist.git
2. cd <YourProjectName>
3. Pod install
4. Open <YourProjectName>.xcworkspace
