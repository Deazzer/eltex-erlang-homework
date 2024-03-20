%%----------------------------------------------------------------------------------------------
%% @autor VarlanKuanyshev
%% @doc
%%  Модуль реализует работу с SIP-клиентом и осуществляет вызовов через протокол SIP.
%%  Также модуль предоставляет функции старта SIP-клиента,
%% регистрации абонентов и осуществления вызовов по номеру.
%% @end
%%----------------------------------------------------------------------------------------------
-module(webrtp_nksip).
-author("VarlanKuanyshev").

-include_lib("kernel/include/logger.hrl").

%% API
-export([start/0]).
-export([register/1]).
-export([call_abonent/1]).


-define(SERVER_NAME, sip_test).
-define(PASS, "1234").

%% @doc Starts the SIP client
-spec start() -> {ok, pid()} | {error, term()}.

start() ->
  nksip:start_link(?SERVER_NAME,
    #{sip_listen => "<sip:all:5060>",
      plugins => [nksip_uac_auto_auth],
      sip_from => "sip:101@test.group"
      }).

%% @doc Abonent registration
-spec register(UserNum :: non_neg_integer()) ->
                {ok, registred} | {error, not_registred}.

register(UserNum) ->

  Uri = "<sip:" ++ integer_to_list(UserNum) ++ "@10.0.20.11:5060;transport=tcp>",
  {ok, StatusCode, [_]} =
    nksip_uac:register(?SERVER_NAME,
      Uri,
      [{sip_pass, ?PASS},
        contact,
        {get_meta, [<<"contact">>]}
      ]
    ),

  case StatusCode of

    200 ->
      ?LOG_NOTICE("Abonent ~p has been successfully registered~n", [UserNum]),
      {ok, registred};

    _ ->
      ?LOG_NOTICE("That abonent ~p was not registered, code: ~p ~n", [UserNum, StatusCode]),
      {error, not_registred}
  end.

%% @doc Abonent-call
-spec call_abonent(Number :: non_neg_integer()) ->
  {ok, called} | {error, term()}.

call_abonent(Number) ->
  CodecInfo = [{<<"audio">>, 1080, [{rtpmap, 0, <<"PCMU/8000">>}, <<"sendrecv">>]}],
  Abonent = "<sip:" ++ integer_to_list(Number) ++ "@10.0.20.11:5060;transport=tcp>",

  try
    {ok, StatusCode, DialogInfo} = nksip_uac:invite(?SERVER_NAME,
      Abonent,
      [
        {sip_pass, ?PASS},
        {body, nksip_sdp:new("auto.nksip", CodecInfo)},
         auto_2xx_ack
      ]),

    case StatusCode of

      200 ->
        ?LOG_NOTICE("Abonent ~p was called!", [Number]),
        [{dialog, DialogId}] = DialogInfo,
        {ok, Meta} = nksip_dialog:get_meta(invite_remote_sdp, DialogId),
        [Media] = element(18, Meta),
        Port = element(3, Media),
        IpInfo = element(8, Media),
        PBX_IP = element(3, IpInfo),

        %% Sending voice
        ConvertVoice = "ffmpeg -i priv/voice/generate.wav -codec:a pcm_mulaw -ar 8000 -ac 1 priv/voice/output.wav -y",
        StartVoice = "./voice_client priv/voice/output.wav " ++ erlang:binary_to_list(PBX_IP) ++ " " ++ erlang:integer_to_list(Port),
        Cmd = ConvertVoice ++ " && " ++ StartVoice,
        os:cmd(Cmd),
        nksip_uac:bye(DialogId, []),
        {ok, called};

      403 ->
        ?LOG_NOTICE("Abonent ~p did not respond", [Number]),
        not_respond;

      480 ->
        ?LOG_NOTICE("Dialog did not started!"),
        dialog_not_started;

      486 ->
        ?LOG_NOTICE("Sorry, Abonent ~p is busy!", [Number]),
        busy
    end

  catch
    {error, Reason} ->
      ?LOG_ERROR("Сaller's call error ~p: ~p", [Number, Reason]),
      {error, Reason}
  end.
