## 2.5.0

* Fixed dangerous YAML loading vulnerability
* Rebuilt integration tests

## 2.3.2

* Fix sqlite3 adapter error

## 2.3.1

* Fix Rails 5.2 deprecation warning

## 2.3.0

* Drop ruby 1.9 and add 2.3 support
* Add an option to skip loading
* Remove excessive debug statement

## 2.2.0

* Add rails config aenerator
* Add NOT NULL checks for latitude and longitude, otherwise nonsense
  values are being returned for distance calculations involving such
  objects.
* Fix inconsistent case where retrieve_location_from_cookie_or_services
  returned a Hash instead of a GeoLoc
* Speed up SQL with bounding box
* Tests against rails 4 & 5

## 2.1.0

* Add OracleEnhanced adapter
* Fix bug with custom latitude/longitude names
* BREAKING: Nearest and fathest return scopes not arrays
* Drop support for ruby 1.8/1.9

## 2.0.1

* Fix GeoKit naming compatibility

## 2.0.0 / 2013-06-19

* Integrated geokit-rails3 into geokit-rails  (use 1.x for rails2 support)

## 1.2.0 / 2009-10-02

* Overhaul the test suite to be independent of a Rails project
* Added concept of database adapter. Ported mysql/postgresql conditional code to their own adapter.
* Added SQL Server support. THANKS http://github.com/brennandunn for all the improvements in this release

## 1.1.3 / 2009-09-26

* documentation updates and updated to work with Geokit gem v1.5.0
* IMPORTANT: in the Geokit gem, Geokit::Geocoders::timeout became Geokit::Geocoders::request_timeout for jruby compatibility.
The plugin sets this in config/initializers/geokit_config.rb. So if you've upgraded the gem to 1.5.0, you need to
make the change manually from Geokit::Geocoders::timeout to Geokit::Geocoders::request_timeout in config/initializers/geokit_config.rb

## 1.1.2 / 2009-06-08

* Added support for hashes in :through. So you can do: acts_as_mappable :through => { :state => :country } (Thanks José Valim).

## 1.1.1 / 2009-05-22
* Support for multiple ip geocoders (Thanks dreamcat4)
* Now checks if either :origin OR :bounds is passed, and proceeds with geokit query if this is true (Thanks Glenn Powell)
* Raises a helpful error if someone uses through but the association does not exists or was not defined yet (Thanks José Valim)

## 1.1.0 / 2009-04-11

* Fixed :through usages so that the through model is only included in the query if there 
	is an :origin passed in (Only if it is a geokit search) (Thanks Glenn Powell)
* Move library initialisation into lib/geokit-rails. init.rb uses lib/geokit-rails now (thanks Alban Peignier)
* Handle the case where a user passes a hash to the :conditions Finder option (thanks Adam Greene)
* Added ability to specify domain-specific API keys (Thanks Glenn Powell)

## 2009-02-20

* More powerful assosciations in the Rails Plugin:You can now specify a model as mappable "through" an associated model. 
In other words, that associated model is the actual mappable model with "lat" and "lng" attributes, but this "through" model 
can still utilize all Geokit's "find by distance" finders. Also Rails 2.3 compatibility (thanks github/glennpow)

## 2008-12-18

* Split Rails plugin from geocoder gem
* updated for Rails 2.2.2

## 2008-08-20

* Further fix of distance calculation, this time in SQL. Now uses least() function, which is available in MySQL version 3.22.5+ and postgres versions 8.1+

## 2008-01-16

* fixed the "zero-distance" bug (calculating between two points that are the same)

## 2007-11-12

* fixed a small but with queries crossing meridian, and also fixed find(:closest)

## 2007-10-11

* Fixed Rails2/Edge compatability
