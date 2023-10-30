-module(caseconverter).
-export([to_rub2/1, to_rub3/1,rec_to_rub/1]).
-record(conv_info,{
    type=currency,
    amount=value,
    commission=commission
}).
to_rub2({Type,Amount}=Arg) ->
    Result=
case Arg of
    {usd,Amount} when is_integer(Amount), Amount > 0 -> 
        io:format("Convert ~p to rub, amount ~p~n",[usd,Amount]),
        {ok, 75.5*Amount};
    {euro,Amount} when is_integer(Amount), Amount > 0 ->
        io:format("Convert ~p to rub, amount ~p~n",[euro,Amount]),
        {ok, 80*Amount};
    {lari,Amount} when is_integer(Amount), Amount > 0 ->
        io:format("Convert ~p to rub, amount ~p~n",[lari,Amount]),
        {ok, 29*Amount};
    {peso,Amount} when is_integer(Amount), Amount > 0 ->
        io:format("Convert ~p to rub, amount ~p~n",[peso,Amount]),
        {ok, 3*Amount};
    {krone,Amount} when is_integer(Amount), Amount > 0 ->
        io:format("Convert ~p to rub, amount ~p~n", [peso,Amount]),
        {ok,10*Amount};
    Error ->
        io:format("Can't convert to rub, error ~p~n",[Error]),
        {error,badarg}
end,
io:format("Converted ~p to rub, amount ~p, Result ~p~n",[Type,Amount,Result]),
Result.

to_rub3(Arg) ->
    case Arg of
        {usd,Amount} when is_integer(Amount), Amount > 0 -> 
        io:format("Convert ~p to rub, amount ~p~n",[usd,Amount]),
        {ok, 75.5*Amount};
    {euro,Amount} when is_integer(Amount), Amount > 0 ->
        io:format("Convert ~p to rub, amount ~p~n",[euro,Amount]),
        {ok, 80*Amount};
    {lari,Amount} when is_integer(Amount), Amount > 0 ->
        io:format("Convert ~p to rub, amount ~p~n",[lari,Amount]),
        {ok, 29*Amount};
    {peso,Amount} when is_integer(Amount), Amount > 0 ->
        io:format("Convert ~p to rub, amount ~p~n",[peso,Amount]),
        {ok, 3*Amount};
    {krone,Amount} when is_integer(Amount), Amount > 0 ->
        io:format("Convert ~p to rub, amount ~p~n", [peso,Amount]),
        {ok,10*Amount};
    Error ->
        io:format("Can't convert to rub, error ~p~n",[Error]),
        {error,badarg}
end.
rec_to_rub(#conv_info{type=usd,amount=Amount,commission=Commission}) when is_integer(Amount), Amount > 0 ->
    ConvAmount = Amount * 75.5,
    CommissionResult = ConvAmount * Commission,
    {ok,ConvAmount-CommissionResult};
rec_to_rub(#conv_info{type=peso,amount=Amount,commission=Commission}) when is_integer(Amount), Amount > 0 ->
    ConvAmount = Amount * 3,
    CommissionResult = ConvAmount * Commission,
    {ok,ConvAmount-CommissionResult};
rec_to_rub(#conv_info{type=euro,amount=Amount,commission=Commission}) when is_integer(Amount), Amount > 0 ->
    ConvAmount = Amount * 80,
    CommissionResult = ConvAmount * Commission,
    {ok,ConvAmount-CommissionResult};
rec_to_rub(#conv_info{type=lari,amount=Amount,commission=Commission}) when is_integer(Amount), Amount > 0 ->
    ConvAmount = Amount * 29,
    CommissionResult = ConvAmount * Commission,
    {ok,ConvAmount-CommissionResult};
rec_to_rub(#conv_info{type=krone,amount=Amount,commission=Commission}) when is_integer(Amount), Amount > 0 ->
    ConvAmount = Amount * 10,
    CommissionResult = ConvAmount * Commission,
    {ok,ConvAmount-CommissionResult};
rec_to_rub(Error) ->
    io:format("Error convertation to rub ~p~n",[Error]),
    {error,badarg}.