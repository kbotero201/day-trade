# day-trade

# DJ-CLI app notes/pitch
Description: An app where users can learn and practice day trading with false money. Try to top the leaderboard and compete with friends! 

Utilize Alpha Advantage Stock Data Api, JSON gem, & TTY prompt gem.


# Models, Attributes, and Associations
User: username, password

Playlist: user_id, name, category/genre/vibe?

Track: (all the built in info from Spotify: artist, album, duration, browser url, etc)

Review: user_id, playlist_id

playlistUser: playlist_id, user_id

playlistTrack: playlist_id, track_id

User has_many Playlists

User has_many Reviews

User has_many Tracks through Playlists

User has_many Artists through Tracks

Playlist belongs_to User (creator relationship)

Playlist has_many Users (listener relationship)

Playlist has_many Reviews

Playlist has_many Tracks

Track has_many Playlists

Track has_many Users through Playlists

Review belongs_to User

Review belongs_to Playlist

# Relationship Chart
User => Game <= Stock 

#self referentials?

User => Review <= Playlist (same structure as playlistUser, but not all Users will leave reviews for every Playlist they listen to)
			 
# User Stories
!!!As a User, I can search through all created Playlists ###DONE###

!!!As a User, I can select and save Playlists to my library listen to ###DONE###

As a User, I can remove Playlists from my library ###DONE###

As a User, I can leave/edit/delete reviews on Playlists

!!!As a User, I can create and populate Playlists

!!!As a User, I can directly input a song into one of my Playlists

As a User, I can generate some Tracks for a Playlist by various search methods: genre, artist, popularity, etc.

As A User, I can see how many Users are listening to which of my Playlists

## KNOWN IMPROVEMENTS NEEDED

Edit existing has bug if u dont have any to edit

Delete has bug 

Need more back buttons everywhere
