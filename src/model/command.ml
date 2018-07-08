
type user = string
type mode = string
type mask = string
type service = string
type server = string
type keyed_channel = Channel.t * Channel.key option

type target =
  | Channel of Channel.t
  | Nickname of Nickname.t

type t =
  (* These commands are taken from RFC 2812 *)

  (* 3.1 Connection Registration *)
  | Pass of string
  | Nick of Nickname.t
  | User of user * mode * string
  | Oper of string * string
  (* | Mode of string * string list *) (*FIXME: chan vs. user modes*)
  | Service of string * string * string * string * string * string
  | Quit of string
  | Squit of string * string

  (* 3.2 Channel operations *)
  | Join of keyed_channel list
  | Join0
  | Part of Channel.t list * string
  | Mode of string * string list
  | Topic of string * string option
  | Names of string option * string option
  | List of string option * string option
  | Invite of string * string
  | Kick of string * string * string option

  (* 3.3 Sending messages *)
  | Privmsg of target * string
  | Notice of string * string

  (* 3.4 Server queries and commands *)
  | Motd of string option
  | Lusers of string option * string option
  | Version of string option
  | Stats of string option * string option
  | Links of string option * string option
  | Time of string option
  | Connect of string * int * string option
  | Trace of string option
  | Admin of string option
  | Info of string option

  (* 3.5 Squery *)
  | Servlist of mask option * string option
  | Squery of service * string

  (* 3.6 Who query *)
  | Who of mask * bool
  | Whois of mask list * server option
  | Whowas of Nickname.t * int option * string option

  (* 3.7 Miscellaneous messages *)
  | Kill of string * string
  | Ping of server * server option
  | Pong of server * server option
  | Error of string

  (* 5.1 Command responses *)
  | Rpl of Reply.t

  (* 5.2 Error replies *)
  | Err of Error.t

let fpf = Format.fprintf

let pp_print_target ppf = function
  | Channel c -> Channel.pp_print ppf c
  | Nickname n -> Nickname.pp_print ppf n

let pp_print ppf = function

  (* JOIN *)
  | Join [] ->
     fpf ppf "JOIN 0"
  | Join keyed_channels ->
     fpf ppf "JOIN";
     let keyed_channels =
       List.sort
         (fun (_, k1) (_, k2) ->
           match k1 , k2 with
           | None , Some _ -> 1
           | Some _ , None -> -1
           | _ -> 0)
         keyed_channels
     in
     let channels , keys =
       List.split keyed_channels
     in
     let keys =
       List.filter (fun o -> o <> None) keys
       |> List.map (function Some k -> k | None -> assert false)
     in
     fpf ppf " %s" (String.concat "," (List.map Channel.to_string channels));
     if keys <> [] then
       fpf ppf " %s" (String.concat "," keys)

  (* NICK *)
  | Nick nick ->
     fpf ppf "NICK %a" Nickname.pp_print nick

  (* USER *)
  | User (user, mode, realname) ->
     fpf ppf "USER %s %s * :%s" user mode realname

  (* 3.3 Sending messages *)
  | Privmsg (target, message) ->
     fpf ppf "PRIVMSG %a :%s" pp_print_target target message

  (* 3.7 Miscellaneous messages *)
  | Ping (server, None) ->
     fpf ppf "PING :%s" server
  | Ping (server1, Some server2) ->
     fpf ppf "PING %s :%s" server1 server2
  | Pong (server, None) ->
     fpf ppf "PONG :%s" server
  | Pong (server1, Some server2) ->
     fpf ppf "PONG %s :%s" server1 server2
  | Error message ->
     fpf ppf "ERROR :%s" message

  (* 5.1 Command responses *)
  | Rpl reply ->
     Reply.pp_print ppf reply

  (* 5.2 Error replies *)
  | Err error ->
     Error.pp_print ppf error

  | _ -> assert false


let from_strings command params =
  match command with

  (* 3.1 Connection Registration *)

  | "NICK" ->
     (
       match params with
       | [] ->
          raise Error.(Exception NoNicknameGiven)
       | nick :: _ ->
          (
            try
              Nick (Nickname.of_string nick)
            with
              Invalid_argument _ ->
              raise Error.(Exception (ErroneousNickname nick))
          )
     )

  | "USER" ->
     (
       match params with
       | user :: mode :: _unused :: realname :: _ ->
          User (user, mode, realname) (*FIXME: mode*)
       | _ ->
          raise Error.(Exception (NeedMoreParams "USER"))
     )

  (* 3.2 Channel operations *)

  | "JOIN" ->
     (
       match params with
       | ["0"] ->
          Join0
       | [channels] ->
          (
            Join
              (
                let channels = String.split_on_char ',' channels in
                List.map
                  (fun channel ->
                    try
                      (Channel.of_string channel, None)
                    with
                      Invalid_argument _ ->
                      raise Error.(Exception (NoSuchChannel channel)))
                  channels
              )
          )
       | channels :: keys :: _ ->
          (
            Join
              (
                let channels = String.split_on_char ',' channels in
                let keys = String.split_on_char ',' keys in
                let rec process_channels_and_keys channels keys =
                  match channels, keys with
                  | [], _ -> []
                  | channel :: channels , [] ->
                     (
                       try
                         (Channel.of_string channel, None)
                         :: process_channels_and_keys channels []
                       with
                         Invalid_argument _ ->
                         raise Error.(Exception (NoSuchChannel channel))
                     )
                  | channel :: channels , key :: keys ->
                     (
                       try
                         (Channel.of_string channel, Some key)
                         :: process_channels_and_keys channels keys
                       with
                         Invalid_argument _ ->
                         raise Error.(Exception (NoSuchChannel channel))
                     )
                in
                process_channels_and_keys channels keys
              )
          )
       | _ ->
          raise Error.(Exception (NeedMoreParams "JOIN"))
     )

  (* 3.3 Sending messages *)

  | "PRIVMSG" ->
     (
       match params with
       | [] ->
          raise Error.(Exception NoRecipient)
       | [_] ->
          raise Error.(Exception NoTextToSend)
       | target :: message :: _ ->
          (
            try
              (* FIXME: target can be more than just channel or nickname *)
              Privmsg (Channel (Channel.of_string target), message)
            with
              Invalid_argument _ ->
              Privmsg (Nickname (Nickname.of_string target), message)
          )
     )

  (* 3.4 Server queries and commands *)

  (* 3.5 Squery *)

  (* 3.6 Who query *)

  (* 3.7 Miscellaneous messages *)

  | "PING" ->
     (
       match params with
       | [source] ->
          Ping (source, None)
       | bouncer :: source :: _ ->
          Ping (source, Some bouncer)
       | _ ->
          raise Error.(Exception NoOrigin)
     )

  (* Unknown commands *)

  | command ->
     raise Error.(Exception (UnknownCommand command))