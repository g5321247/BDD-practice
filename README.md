# Spec
[![Build Status](https://travis-ci.com/g5321247/BDD-practice.svg?branch=master)](https://travis-ci.com/g5321247/BDD-practice)

## Story
Customer requests to see their image feed

## Narrative #1
(1) As a person with role X
(2) I want to do Y
(3) So I can achieve Z

1. As an online customer
2. I want the app to automatically load my latest image feed
3. So I can always enjoy the newest images of my friends

Scenarios (Acceptance criteria)
- `Given` customer has connectivity 
- `When` the customer requests to see their feed
- `Then` the app should display latest feed from remote
- `And` replace the cache with the new feed

## Narrative #2

1. As an offline customer
2. I want the app to show the latest saved version of my image feed
3. So I can always enjoy image with my friends

Scenarios (Acceptance criteria)
- `Given` customer has no connectivity 
- `And`  there’s a cache version of the feed
- `And`  the cache is less than 7 days old 
- `When` the customer requests to see their feed
- `Then` the app should display latest feed from cached

Scenarios (Acceptance criteria)
- `Given` customer has no connectivity 
- `And`  there’s a cache version of the feed
- `And`  the cache is 7 days old or more
- `When` the customer requests to see their feed
- `Then` the app should display latest feed from cached

Scenarios (Acceptance criteria)
`Given` customer has no connectivity 
`And` the cahed is Empty
`When` the customer requests to see their feed
`Then` the app should display error message

# Use Case 
## Load Feed From Remote Use Case
### Data
- URL
 
### Primary Course(happy path)
1. Execute "Load Image Feed" command with above data.
2. System downloads data from the URL.
3. System validates downloaded data.
4. System creates image feed from valid data.
5. System delivers image feed.

### Invalid data – error course (sad path):
1. System delivers invalid data error.

### No connectivity – error course (sad path):
1. System delivers connectivity error.

## Load Feed From Cache Use Case

### Primary Course(happy path)
1. Execute “Load Feed Items” command with above data.
2. System fetches feed data from cache.
3. System validates cache is less than 7 days old.
4. System creates feed items from cached data.
5. System delivers feed items.

### Error course(sad path)
1. System delivers error.

### Expired cache(sad path)
1. System deletes cache.
2. System delivers no feed images.

### Empty cache(sad path)
1. System delivers no feed images.

## Save Feed Items Use Case
### Data
Image Feed

(2) Primary course (happy path)
1. Execute “Save Feed Items” command with above data.
2. System deletes the old cache data.
3. System encodes feed items.
4. System timestamps the new cache.
5. System saves the new cache data.
6. System delivers a success message.

### Deleting error course(sad path)
1. System delivers error.

### Saving error course(sad path)
1. System delivers error.

# Flowchart
![](https://i.imgur.com/ngke8wm.png)

