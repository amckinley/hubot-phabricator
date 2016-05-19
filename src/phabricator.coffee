# Description
#   Auto-reply with descriptions and links to phabricator objects
#
# Dependencies:
#   "requests": "^0.1.7"
#
# Configuration:
#   HUBOT_PHABRICATOR_API=api-uri
#   HUBOT_PHABRICATOR_API_TOKEN=api-xxxxxxxx
#   HUBOT_PHABRICATOR_IGNORE=[T1000,D999,etc]
#
# Commands:
#   [TDPQFV]12345 - respond with a description of the phabricator object referenced
#
# Author:
#   kemayo

module.exports = (robot) ->
  ignore = (process.env.HUBOT_PHABRICATOR_IGNORE || '').replace(/\s+/g, '').split(',')

  # object (the TDPQFV bit is the things we recognize as prefixes)
  robot.hear /(?:^|[\[\s])([TDPQFV][0-9]+|r[A-Z]+[a-f0-9]+)(?:\s*(-v))?(?=\W|$)/g, (msg) ->
    matched_names = (match.trim() for match in msg.match when match.trim() not in ignore)
    if matched_names.length == 0
      return
    params = {
      "api.token": process.env.HUBOT_PHABRICATOR_API_TOKEN,
      names: matched_names
    }
    request.get {
      uri: process.env.HUBOT_PHABRICATOR_API + "/phid.lookup",
      qs: params
    }, (err, r, body) ->
      if err
        console.log "error fetching phabricator objects: #{err}"
        return
      data = JSON.parse body
      hits = ("^ #{info.fullName} - #{info.uri}" for phid, info of data.result).join("\n")
      if hits
        msg.send hits
