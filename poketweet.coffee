PokemonGO = require('pokemon-go-node-api')
config = require('./config.json')
_ = require('lodash');

# using var so you can login with multiple users
a = new (PokemonGO.Pokeio)
#Set environment variables or replace placeholder text
location =
  type: 'name'
  name: config.StartingLocation
username = config.PTCUsername
password = config.PTCPassword
provider = config.Provider


tellProfileInfo = (err, profile) ->
  if err
    throw err
  console.log '[i] Username: ' + profile.username
  console.log '[i] Poke Storage: ' + profile.poke_storage
  console.log '[i] Item Storage: ' + profile.item_storage
  poke = 0
  if profile.currency[0].amount
    poke = profile.currency[0].amount
  console.log '[i] Pokecoin: ' + poke
  console.log '[i] Stardust: ' + profile.currency[1].amount
tellLocationInfo = (err) ->
  if err
    throw err
  console.log '[i] Current location: ' + a.playerInfo.locationName
  console.log '[i] lat/long/alt: : ' + a.playerInfo.latitude + ' ' + a.playerInfo.longitude + ' ' + a.playerInfo.altitude


tweetPokemon = (pokedexEntry, encounteredPokemon) ->
  if _.indexOf(config.PriorityPokemon, parseInt(pokedexEntry.PokedexNumber)) isnt -1
    console.log "[+] BREAKING NEWS! SUPER RARE! " + pokedexEntry.name + "! Tweeting immediately!"
  else
    console.log "[+] Found " + pokedexEntry.name + "! Tweeting immediately!"

a.init username, password, location, provider, (err) ->
  tellLocationInfo(err)
  locations = config.Locations
  a.GetProfile (err, profile) ->
    tellProfileInfo(err, profile)
    i = 0
    setInterval ( () ->
      if locations[i+1]?
        i++
      else
        i = 0
      console.log "looking for pokemon at ,", locations[i]?.name
      a.SetLocation(locations[i], (error) ->
        if error
          console.log "error :", error
        a.Heartbeat (err, hb) ->
          if err
            console.log err
          for cell in hb?.cells
            if cell.NearbyPokemon[0]
              encounteredPokemon = cell.NearbyPokemon[0]
              pokedexEntry = a.pokemonlist[parseInt(encounteredPokemon.PokedexNumber) - 1]
              console.log '[+] There is a ' + pokedexEntry.name + ' at ' + encounteredPokemon.DistanceMeters.toString() + ' meters'
              console.log "encountered : ", encounteredPokemon.EncounterId
              if _.indexOf(config.ExcludedPokemon, parseInt(pokedexEntry.PokedexNumber))
                console.log "[+] " + pokedexEntry.name + " is not a rare pokemon - Ignoring!"
              else
                tweetPokemon(pokedexEntry, encounteredPokemon)
    #      console.log "looking for pokemon at latitude: " + coordinates.latitude + ", longitude: " + coordinates.longitude
      )
    ), 5000