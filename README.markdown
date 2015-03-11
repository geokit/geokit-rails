Geokit Rails
============

[![Gem Version](https://badge.fury.io/rb/geokit-rails.png)](http://badge.fury.io/rb/geokit-rails)
[![Build Status](https://travis-ci.org/geokit/geokit-rails.png?branch=master)](https://travis-ci.org/geokit/geokit-rails)
[![Coverage Status](https://coveralls.io/repos/geokit/geokit-rails/badge.png)](https://coveralls.io/r/geokit/geokit-rails)
[![Dependency Status](https://gemnasium.com/geokit/geokit-rails.png?travis)](https://gemnasium.com/geokit/geokit-rails)
[![Code Climate](https://codeclimate.com/github/geokit/geokit-rails.png)](https://codeclimate.com/github/geokit/geokit-rails)

## COMMUNICATION

* If you **need help**, use [Stack Overflow](http://stackoverflow.com/questions/tagged/geokit). (Tag 'geokit' and we'll be alerted)
* If you **found a bug**, use GitHub issues.
* If you **have an idea**, use GitHub issues.
* If you'd like to **ask a general question**, use GitHub issues.
* If you **want to contribute**, submit a pull request.

## INSTALLATION

Geokit for Rails consists of a generic Gem ([geokit](https://github.com/geokit/geokit)) and a Rails plugin ([geokit-rails](https://github.com/geokit/geokit-rails)).

Make sure you use a version >= 3.0 of Rails.

You just have to add the 'geokit-rails' gem to your Gemfile

```ruby
gem 'geokit-rails'
```

Then tell bundler to update the gems :

```sh
$ bundle install
```

Last, consult the `important post-installation notes` section at the end of this document.

If you want to use geokit-rails in a Rails 2 application, just use the good old plugin ([geokit-rails](https://github.com/andre/geokit-rails)).


## FEATURE SUMMARY

Geokit provides key functionality for location-oriented Rails applications:

- Distance calculations, for both flat and spherical environments. For example,
  given the location of two points on the earth, you can calculate the miles/Km
  between them.
- ActiveRecord distance-based finders. For example, you can find all the points
  in your database within a 50-mile radius.
- IP-based location lookup utilizing hostip.info. Provide an IP address, and get
  city name and latitude/longitude in return
- A before_filter helper to geocoder the user's location based on IP address,
  and retain the location in a cookie.
- Geocoding from multiple providers. It provides a fail-over mechanism, in case
  your input fails to geocode in one service. Geocoding is provided by the Geokit
  gem, which you must have installed

The goal of this plugin is to provide the common functionality for location-oriented
applications (geocoding, location lookup, distance calculation) in an easy-to-use
package.

## A NOTE ON TERMINOLOGY

Throughout the code and API, _latitude_ and _longitude_ are referred to as _lat_
and _lng_.  We've found over the long term the abbreviation saves lots of typing time.

## LOCATION QUERIES

### MAKING A MODEL MAPPABLE

To get started, just specify an ActiveRecord class as `acts_as_mappable`:

```ruby
class Location < ActiveRecord::Base
  acts_as_mappable
end
```

There are some defaults you can override:

```ruby
class Location < ActiveRecord::Base
  acts_as_mappable :default_units => :miles,
                   :default_formula => :sphere,
                   :distance_field_name => :distance,
                   :lat_column_name => :lat,
                   :lng_column_name => :lng
end
```

The optional parameters are `units`, `formula`, and `distance_field_name`.
Values for **units** can be `:miles`, `:kms` (kilometers), or `:nms` (nautical miles),
with `:miles` as the default. 
Values for **formula** can be `:sphere` or `:flat` with `:sphere` as the default.
`:sphere` gives you Haversine calculations, while `:flat` gives the Pythagoreum Theory.
These defaults persist through out the gem.

The plug-in creates a calculated `distance` field on AR instances that have
been retrieved through a Geokit location query. By default, these fields are
known as "distance" but this can be changed through the `:distance_field_name` key.

You can also define alternative column names for latitude and longitude using
the `:lat_column_name` and `:lng_column_name` keys.  The defaults are `lat` and
`lng` respectively.

### NEW SCOPES TO USE

Once you've specified `acts_as_mappable`, a few scopes are available :

* `within` and `beyond` find records within or beyond a certain distance from the origin point.
* `in_range` finds records within a certain distance range from the origin point.
* `in_bounds` finds records within a rectangle on the map
* `closest` and `farthest` find the closest or farthest record from the origin point
* `by_distance` finds records ordered by distance from the origin point

All these scopes are the porcelain for a lower level scope named `geo_scope` that take a hash of options.
Their first parameter is simply one of  the possible options, without the name

A few examples :

```ruby
Location.within(5, :origin => @somewhere)
# is the same as
Location.geo_scope(:within => 5, :origin => @somewhere)
```    

```ruby
Location.in_range(2..5, :origin => @somewhere)
# is the same as
Location.geo_scope(:range => 2..5, :origin => @somewhere)
```    

```ruby
Location.in_bounds([@south_west_point, @north_east_point], :origin => @somewhere)
# is the same as
Location.geo_scope(:bounds => [@south_west_point, @north_east_point], :origin => @somewhere)
```

The options can be :

`:origin` as a two-element array of latitude/longitude:

```ruby
Location.geo_scope(:origin => [37.792,-122.393])
```

`:origin` as a geocodeable string:

```ruby
Location.geo_scope(:origin => '100 Spear st, San Francisco, CA')
```

`:origin` as an object which responds to `lat` and `lng` methods,
or `latitude` and `longitude` methods, or whatever methods you have
specified for `lng_column_name` and `lat_column_name`:

```ruby
Location.geo_scope(:origin => my_store)
# my_store.lat and my_store.lng methods exist
```

`:units` or `:formula` can be used to override the default values in a specific query

```ruby
Location.within(5, :units => :kms, :origin => @somewhere)
# it will get the records within 5 kilometers instead of 5 miles
```

`:range` as a native Ruby range

`:bounds` as an array of two elements : the south/west point and the north/east point.

```ruby
@sw = Geokit::LatLng.new(32.91663,-96.982841)
@ne = Geokit::LatLng.new(32.96302,-96.919495)
@somewhere = Location.find(123456)
Location.geo_scope(:bounds => [@sw, @ne], :origin => @somewhere)
```

`:bounds` as a Geokit::Bounds object

```ruby
@bounds = Geokit::Bounds.new([32.91663,-96.982841], [32.96302,-96.919495])
@somewhere = Location.find(123456)
Location.geo_scope(:bounds => [@sw, @ne], :origin => @somewhere)
```

When using a point of reference or bounds, you leverage the power of Geokit
to build this objects. Basically, if Geokit can make a Geokit::Point
or a Geokit::Bounds with what you give to it, you're good to go.

### FIND BY SQL

Finally, if all that is desired is the raw SQL for distance
calculations, you can use the following:

```ruby
Location.distance_sql(origin, units = default_units, formula = default_formula)
```

Thereafter, you are free to use it in `find_by_sql` as you wish.

### CHAINABILITY

You can then chain these scope with any other or use a "calling" method like `first`, `all`, `count`, …

```ruby
Location.within(5, :origin => @somewhere).all
Location.within(5, :origin => @somewhere).count
Location.geo_scope(:origin => [37.792,-122.393]).first
```

You can add `order` clauses in the chain as for any ActiveRecord query

```ruby
Location.within(5, :origin => @somewhere).order('nbr_seats ASC')
```

You can even sort by distance (use the same name as specified in the model class)

```ruby
Location.within(5, :origin => @somewhere).order('distance DESC, nbr_seats ASC')
```

Idem for the `limit` clause. In fact, `closest` and `farthest` are defined like this :

```ruby
def closest(options = {})
  geo_scope(options).order("#{distance_column_name} asc").limit(1)
end
def farthest(options = {})
  geo_scope(options).order("#{distance_column_name} desc").limit(1)
end
```

#### Important caveat

In the current version of geokit-rails, it is not possible to add a `where` clause
using the _distance_ column. I've tried many different ways to do this and didn't get it working.

One would expect to build a query like this :

```ruby
scoped  = Location.geo_scope(:origin => @somewhere)
scoped  = scoped.where('distance <= 5)
results = scoped.all
```

This is not possible right now, it must be done in a single step like this :

```ruby
scoped  = Location.within(5, :origin => @somewhere)
results = scoped.all
```

Every good idea that would help achieve this is very much welcome.

### FINDING WITHIN A BOUNDING BOX

If you are displaying points on a map, you probably need to query for whatever falls within the rectangular bounds of the map:

```ruby
Store.in_bounds([sw_point,ne_point]).all
```

The input to `bounds` can be an array with the two points or a Bounds object. However you provide them, the order should always be the southwest corner, northeast corner of the rectangle. Typically, you will be getting the sw\_point and ne\_point from a map that is displayed on a web page.

If you need to calculate the bounding box from a point and radius, you can do that:

```ruby
bounds = Geokit::Bounds.from_point_and_radius(home,5)
Store.in_bounds(bounds).all
```

----

# What is following is from the previous _geokit-rails_ plugin.

> **It has not been tested with Rails 3 nor with this version of the gem.**
**Most of it should work, but it is not sure**


## USING INCLUDES

You can use includes along with your distance finders:

```ruby
stores = Store.within(5, :origin=>home).includes([:reviews,:cities]).order('distance asc').all
```

*However*, ActiveRecord drops the calculated distance column when you use include. So, if you need to use the distance column, you'll have to re-calculate it post-query in Ruby:

```ruby
stores.sort_by{|s| s.distance_to(home)}
```

In this case, you may want to just use the bounding box condition alone in your SQL (there's no use calculating the distance twice):

```ruby
bounds=Geokit::Bounds.from_point_and_radius(home,5)
stores=Store.includes([:reviews,:cities]).in_bounds(bounds)
stores.sort_by{|s| s.distance_to(home)}
```

## USING :through

You can also specify a model as mappable "through" another associated model. In other words, that associated model is the actual mappable model with "lat" and "lng" attributes, but this "through" model can still utilize all of the above find methods to search for records.

```ruby
class Location < ActiveRecord::Base
  belongs_to :locatable, :polymorphic => true
  acts_as_mappable
end
```

```ruby
class Company < ActiveRecord::Base
  has_one :location, :as => :locatable  # also works for belongs_to associations
  acts_as_mappable :through => :location
end
```

Then you can still call:

```ruby
Company.within(distance, :origin => @somewhere)
```

You can also give :through a hash if your location is nested deep. For example, given:

```ruby
class House
  acts_as_mappable
end
```

```ruby
class Family
  belongs_to :house
end
```

```ruby
class Person
  belongs_to :family
  acts_as_mappable :through => { :family => :house }
end
```

Remember that the notes above about USING INCLUDES apply to the results from
this find, since an include is automatically used.

## IP GEOCODING

You can obtain the location for an IP at any time using the geocoder
as in the following example:

```ruby
location = IpGeocoder.geocode('12.215.42.19')
```

where Location is a GeoLoc instance containing the latitude,
longitude, city, state, and country code.  Also, the success
value is true.

If the IP cannot be geocoded, a GeoLoc instance is returned with a
success value of false.

It should be noted that the IP address needs to be visible to the
Rails application.  In other words, you need to ensure that the
requesting IP address is forwarded by any front-end servers that
are out in front of the Rails app.  Otherwise, the IP will always
be that of the front-end server.

The Multi-Geocoder will also geocode IP addresses and provide
failover among multiple IP geocoders. Just pass in an IP address for the
parameter instead of a street address. Eg:

```ruby
location = Geocoders::MultiGeocoder.geocode('12.215.42.19')
```

The MultiGeocoder class requires 2 configuration setting for the provider order.
Ordering is done through `Geokit::Geocoders::provider_order` and
`Geokit::Geocoders::ip_provider_order`, found in
`config/initializers/geokit_config.rb`. If you don't already have a
`geokit_config.rb` file, the plugin creates one when it is first installed.


## IP GEOCODING HELPER

A class method called geocode_ip_address has been mixed into the
ActionController::Base.  This enables before_filter style lookup of
the IP address.  Since it is a filter, it can accept any of the
available filter options.

Usage is as below:

```ruby
class LocationAwareController < ActionController::Base
  geocode_ip_address
end
```

A first-time lookup will result in the GeoLoc class being stored
in the session as `:geo_location` as well as in a cookie called
`:geo_session`.  Subsequent lookups will use the session value if it
exists or the cookie value if it doesn't exist.  The last resort is
to make a call to the web service.  Clients are free to manage the
cookie as they wish.

The intent of this feature is to be able to provide a good guess as
to a new visitor's location.

## INTEGRATED FIND AND GEOCODING

Geocoding has been integrated with the finders enabling you to pass
a physical address or an IP address.  This would look the following:

```ruby
Location.farthest(:origin => '217.15.10.9')
Location.farthest(:origin => 'Irving, TX')
```

where the IP or physical address would be geocoded to a location and
then the resulting latitude and longitude coordinates would be used
in the find.  This is not expected to be common usage, but it can be
done nevertheless.

## ADDRESS GEOCODING

Geocoding is provided by the Geokit gem, which is required for this plugin.
See the top of this file for instructions on installing the Geokit gem.

Geokit can geocode addresses using multiple geocodeing web services.
Geokit supports services like Google, Yahoo, and Geocoder.us, and more --
see the Geokit gem API for a complete list.

These geocoder services are made available through the following classes:
GoogleGeocoder, YahooGeocoder, UsGeocoder, CaGeocoder, and GeonamesGeocoder.
Further, an additional geocoder class called MultiGeocoder incorporates an ordered failover
sequence to increase the probability of successful geocoding.

All classes are called using the following signature:

```ruby
include Geokit::Geocoders
location = XxxGeocoder.geocode(address)
```

where you replace Xxx Geocoder with the appropriate class.  A GeoLoc
instance is the result of the call.  This class has a "success"
attribute which will be true if a successful geocoding occurred.
If successful, the lat and lng properties will be populated.

Geocoders are named with the convention NameGeocoder.  This
naming convention enables Geocoder to auto-detect its sub-classes
in order to create methods called `name_geocoder(address)` so that
all geocoders can be called through the base class.  This is done
purely for convenience; the individual geocoder classes are expected
to be used independently.

The MultiGeocoder class requires the configuration of a provider
order which dictates what order to use the various geocoders.  Ordering
is done through `Geokit::Geocoders::provider_order`, found in
`config/initializers/geokit_config.rb`.

If you don't already have a `geokit_config.rb` file, the plugin creates one
when it is first installed.

Make sure your failover configuration matches the usage characteristics
of your application -- for example, if you routinely get bogus input to
geocode, your code will be much slower if you have to failover among
multiple geocoders before determining that the input was in fact bogus.

The Geocoder.geocode method returns a GeoLoc object. Basic usage:

```ruby
loc=Geocoder.geocode('100 Spear St, San Francisco, CA')
if loc.success
  puts loc.lat
  puts loc.lng
  puts loc.full_address
end
```

## REVERSE GEOCODING

Currently, only the Google Geocoder supports reverse geocoding.
Pass the lat/lng as a string, array or LatLng instance:

```ruby
res=Geokit::Geocoders::GoogleGeocoder.reverse_geocode "37.791821,-122.394679"
=> #<Geokit::GeoLoc:0x558ed0 ...
res.full_address "101-115 Main St, San Francisco, CA 94105, USA"
```

The address will usually appear as a range, as it does in the above example.


## INTEGRATED FIND WITH ADDRESS GEOCODING

Just has you can pass an IP address directly into an ActiveRecord finder
as the origin, you can also pass a physical address as the origin:

```ruby
Location.find_closest(:origin => '100 Spear st, San Francisco, CA')
```

where the physical address would be geocoded to a location and then the
resulting latitude and longitude coordinates would be used in the
find.

Note that if the address fails to geocode, the find method will raise an
ActiveRecord::GeocodeError you must be prepared to catch. Alternatively,
You can geocoder the address beforehand, and pass the resulting lat/lng
into the finder if successful.

## Auto Geocoding

If your geocoding needs are simple, you can tell your model to automatically
geocode itself on create:

```ruby
class Store < ActiveRecord::Base
  acts_as_mappable :auto_geocode=>true
end
```

It takes two optional params:

```ruby
class Store < ActiveRecord::Base
  acts_as_mappable :auto_geocode=>{:field=>:address, :error_message=>'Could not geocode address'}
end
```

. . . which is equivalent to:

```ruby
class Store << ActiveRecord::Base
  acts_as_mappable
  before_validation :geocode_address, :on => :create

  private
  def geocode_address
    geo=Geokit::Geocoders::MultiGeocoder.geocode (address)
    errors.add(:address, "Could not Geocode address") if !geo.success
    self.lat, self.lng = geo.lat,geo.lng if geo.success
  end
end
```

If you need any more complicated geocoding behavior for your model, you should roll your own
`before_validate` callback.


## Distances, headings, endpoints, and midpoints

```ruby
distance = home.distance_from(work, :units=>:miles)
heading  = home.heading_to(work) # result is in degrees, 0 is north
endpoint = home.endpoint(90,2)  # two miles due east
midpoint = home.midpoint_to(work)
```

## Cool stuff you can do with bounds

```ruby
bounds = Bounds.new(sw_point,ne_point)
bounds.contains?(home)
puts bounds.center
```

HOW TO . . .
=================================================================================

A few quick examples to get you started ....

## How to install the Geokit Rails plugin
(See the very top of this file)

## How to find all stores within a 10-mile radius of a given lat/lng
1. ensure your stores table has lat and lng columns with numeric or float
   datatypes to store your latitude/longitude

2. use `acts_as_mappable` on your store model:
3. 
  ```ruby
  class Store < ActiveRecord::Base
     acts_as_mappable
     ...
  end
  ```
  
3. finders now have extra capabilities:
  
  ```ruby
  Store.find(:all, :origin =>[32.951613,-96.958444], :within=>10)
  ```
  
## How to geocode an address

1. configure your geocoder key(s) in `config/initializers/geokit_config.rb`

2. also in `geokit_config.rb`, make sure that `Geokit::Geocoders::provider_order` reflects the
   geocoder(s). If you only want to use one geocoder, there should
   be only one symbol in the array. For example:

  ```ruby
  Geokit::Geocoders::provider_order=[:google]
  ```
  
3. Test it out in script/console

  ```ruby
  include Geokit::Geocoders
  res = MultiGeocoder.geocode('100 Spear St, San Francisco, CA')
  puts res.lat
  puts res.lng
  puts res.full_address
  ```
  
    ... etc. The return type is GeoLoc, see the API for
    all the methods you can call on it.

## How to find all stores within 10 miles of a given address

1. as above, ensure your table has the lat/lng columns, and you've
   applied `acts_as_mappable` to the Store model.

2. configure and test out your geocoder, as above

3. pass the address in under the :origin key

  ```ruby
  Store.find(:all, :origin=>'100 Spear st, San Francisco, CA', :within=>10)
  ```
  
4. you can also use a zipcode, or anything else that's geocodable:

  ```ruby
  Store.find(:all, :origin=>'94117', :conditions=>'distance<10')
  ```
  
## How to sort a query by distance from an origin

You now have access to a 'distance' column, and you can use it
as you would any other column. For example:

```ruby
Store.find(:all, :origin=>'94117', :order=>'distance')
```

## How to sort elements of an array according to distance from a common point

Usually, you can do your sorting in the database as part of your find call.
If you need to sort things post-query, you can do so:

```ruby
stores = Store.all
stores.sort_by{|s| s.distance_to(home)}
```

Obviously, each of the items in the array must have a latitude/longitude so
they can be sorted by distance.

## Database indexes

MySQL can't create indexes on a calculated field such as those Geokit uses to
calculate distance based on latitude/longitude values for a record.  However,
indexing the lat and lng columns does improve Geokit distance calculation
performance since the lat and lng columns are used in a straight comparison
for distance calculation.  Assuming a Page model that is incorporating the
Geokit plugin the migration would be as follows.

```ruby
class AddIndexToPageLatAndLng < ActiveRecord::Migration

  def self.up
    add_index  :pages, [:lat, :lng]
  end

  def self.down
    remove_index  :pages, [:lat, :lng]
  end
end
```

## Database Compatability

* Geokit works with MySQL (tested with version 5.0.41), PostgreSQL (tested with version 8.2.6) and Microsoft SQL Server (tested with 2000).
* Geokit is known to *not* work with Postgres versions under 8.1 -- it uses the least() funciton.


## HIGH-LEVEL NOTES ON WHAT'S WHERE

`acts_as_mappable.rb`, as you'd expect, contains the ActsAsMappable
module which gets mixed into your models to provide the
location-based finder goodness.

`ip_geocode_lookup.rb` contains the before_filter helper method which
enables auto lookup of the requesting IP address.

### The Geokit gem provides the building blocks of distance-based operations:

The Mappable module, which provides basic
distance calculation methods, i.e., calculating the distance
between two points.

The LatLng class  is a simple container for latitude and longitude, but
it's made more powerful by mixing in the above-mentioned Mappable
module -- therefore, you can calculate easily the distance between two
LatLng objects with `distance = first.distance_to(other)`

GeoLoc represents an address or location which
has been geocoded. You can get the city, zipcode, street address, etc.
from a GeoLoc object. GeoLoc extends LatLng, so you also get lat/lng
AND the Mappable module goodness for free.

## IMPORTANT POST-INSTALLATION NOTES:

*1. The configuration file*: Geokit for Rails uses a configuration file in config/initializers.
You *must* add your own keys for the various geocoding services if you want to use geocoding.
If you need to refer to the original template again, see the `assets/api_keys_template` file.

*2. The gem dependency*: Geokit for Rails depends on the Geokit gem. Tell Rails about this
dependency in `config/environment.rb`, within the initializer block:
config.gem "geokit"
