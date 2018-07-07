
type t =
  | NoSuchNick of Nickname.t
  | NoSuchServer of string
  | NoSuchChannel of string
  | CannotSendToChan of Channel.t
  | TooManyChannels of Channel.t
  | WasNoSuchNick of Nickname.t
  | TooManyTargets of string * string * string
  | NoSuchService of string
  | NoOrigin
  | NoRecipient
  | NoTextToSend
  | NoTopLevel of string
  | WildTopLevel of string
  | BadMask of string
  | UnknownCommand of string
  | NoMotd
  | NoAdminInfo of string
  | FileError of string * string
  | NoNicknameGiven
  | ErroneousNickname of string
  | NicknameInUse of Nickname.t
  | NickCollision of string * string * string
  | UnavailResource of string
  | UserNotInChannel of Nickname.t * Channel.t
  | NotOnChannel of Channel.t
  | UserOnChannel of Nickname.t * Channel.t
  | NoLogin of string
  | SummonDisabled
  | UsersDisabled
  | NotRegistered
  | NeedMoreParams of string
  | AlreadyRegistered
  | NoPermFromHost
  | PasswdMismatch
  | YoureBannedCreep
  | YouWillBeBanned
  | KeySet of Channel.t
  | ChannelIsFull of Channel.t
  | UnknownMode of char * Channel.t
  | InviteOnlyChan of Channel.t
  | BannedFromChan of Channel.t
  | BadChannelKey of Channel.t
  | BadChanMask of Channel.t
  | NoChanModes of Channel.t
  | BanListFull of Channel.t * char
  | NoPrivileges
  | ChanopPrivNeeded of Channel.t
  | CantKillServer
  | Restricted
  | UniqOpPrivNeeded
  | NoOperHost
  | UModeUnknownFlag
  | UsersDontMatch

exception Exception of t
  
let fpf = Format.fprintf

let pp_print ppf = function
  | NoSuchNick nick ->
     fpf ppf "401 %a :No such nick/channel" Nickname.pp_print nick
  | NoSuchServer server ->
     fpf ppf "402 %s :No such server" server
  | NoSuchChannel channel ->
     fpf ppf "403 %s :No such channel" channel
  | CannotSendToChan channel ->
     fpf ppf "404 %a :Cannot send to channel" Channel.pp_print channel
  | TooManyChannels channel ->
     fpf ppf "405 %a :You have joined too many channels" Channel.pp_print channel
  | WasNoSuchNick nick ->
     fpf ppf "406 %a :There was no such nickname" Nickname.pp_print nick
  | TooManyTargets (target, code, message) ->
     fpf ppf "407 %s :%s recipients. %s" target code message
  | NoSuchService service ->
     fpf ppf "408 %s :No such service" service
  | NoOrigin ->
     fpf ppf "409 :No origin specified"
  | NoRecipient ->
     fpf ppf "411 :No recipient given"
  | NoTextToSend ->
     fpf ppf "412 :No text to send"
  | NoTopLevel mask ->
     fpf ppf "413 %s :No toplevel domain specified" mask
  | WildTopLevel mask ->
     fpf ppf "414 %s :Wildcard in toplevel domain" mask
  | BadMask mask ->
     fpf ppf "415 %s :Bad Server/host mask" mask
  | UnknownCommand command ->
     fpf ppf "421 %s :Unknown command" command
  | NoMotd ->
     fpf ppf "422 :MOTD File is missing"
  | NoAdminInfo server ->
     fpf ppf "423 %s :No administrative info available" server
  | FileError (op, file) ->
     fpf ppf "424 :File error doing %s on %s" op file
  | NoNicknameGiven ->
     fpf ppf "431 :No nickname given"
  | ErroneousNickname nick ->
     fpf ppf "432 %s :Erroneous nickname" nick
  | NicknameInUse nick ->
     fpf ppf "433 %a :Nickname is already in use" Nickname.pp_print nick
  | NickCollision (nick, user, host) ->
     fpf ppf "436 %s :Nickname collision KILL from %s@%s" nick user host
  | UnavailResource nick_chan ->
     fpf ppf "437 %s :Nick/channel is temporarily unavailable" nick_chan
  | UserNotInChannel (nick, chan) ->
     fpf ppf "441 %a %a :They aren't on that channel" Nickname.pp_print nick Channel.pp_print chan
  | NotOnChannel chan ->
     fpf ppf "442 %a :You're not on that channel" Channel.pp_print chan
  | UserOnChannel (nick, chan) ->
     fpf ppf "443 %a %a :is already on channel" Nickname.pp_print nick Channel.pp_print chan
  | NoLogin user ->
     fpf ppf "444 %s :User not logged in" user
  | SummonDisabled ->
     fpf ppf "445 :SUMMON has been disabled"
  | UsersDisabled ->
     fpf ppf "446 :USERS has been disabled"
  | NotRegistered ->
     fpf ppf "451 :You have not registered"
  | NeedMoreParams command ->
     fpf ppf "461 %s :Not enough parameters" command
  | AlreadyRegistered ->
     fpf ppf "462 :Unauthorized command (already registered)"
  | NoPermFromHost ->
     fpf ppf "463 :Your host isn't among the privileged"
  | PasswdMismatch ->
     fpf ppf "464 :Password incorrect"
  | YoureBannedCreep ->
     fpf ppf "465 :You are banned from this server"
  | YouWillBeBanned ->
     fpf ppf "466 :You will be banned from this server"
  | KeySet channel ->
     fpf ppf "467 %a :Channel key already set" Channel.pp_print channel
  | ChannelIsFull channel ->
     fpf ppf "471 %a :Cannot join channel (+l)" Channel.pp_print channel
  | UnknownMode (mode, channel) ->
     fpf ppf "472 %c :is unknown mode char to me for %a" mode Channel.pp_print channel
  | InviteOnlyChan channel ->
     fpf ppf "473 %a :Cannot join channel (+i)" Channel.pp_print channel
  | BannedFromChan channel ->
     fpf ppf "474 %a :Cannot join channel (+b)" Channel.pp_print channel
  | BadChannelKey channel ->
     fpf ppf "475 %a :Cannot join channel (+k)" Channel.pp_print channel
  | BadChanMask channel ->
     fpf ppf "476 %a :Bad Channel Mask" Channel.pp_print channel
  | NoChanModes channel ->
     fpf ppf "477 %a :Channel doesn't support modes" Channel.pp_print channel
  | BanListFull (channel, char) ->
     fpf ppf "478 %a %c :Channel list is full" Channel.pp_print channel char
  | NoPrivileges ->
     fpf ppf "481 :Permission Denied- You're not an IRC operator"
  | ChanopPrivNeeded channel ->
     fpf ppf "482 %a :You're not channel operator" Channel.pp_print channel
  | CantKillServer ->
     fpf ppf "483 :You can't kill a server!"
  | Restricted ->
     fpf ppf "484 :Your connection is restricted!"
  | UniqOpPrivNeeded ->
     fpf ppf "485 :You're not the original channel operator"
  | NoOperHost ->
     fpf ppf "491 :No O-lines for your host"
  | UModeUnknownFlag ->
     fpf ppf "501 :Unknown MODE flag"
  | UsersDontMatch ->
     fpf ppf "502 :Cannot change mode for other users"