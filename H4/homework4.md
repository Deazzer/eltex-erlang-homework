%% Задание 1
    7> caseconverter:to_rub2({usd,100}).
Convert usd to rub, amount 100
Converted usd to rub, amount 100, Result {ok,7550.0}
{ok,7550.0}
    8> caseconverter:to_rub3({usd,100}).
Convert usd to rub, amount 100
{ok,7550.0}
    9> caseconverter:to_rub3({peso,12}).
Convert peso to rub, amount 12
{ok,36}
    10> caseconverter:to_rub2({peso,12}).
Convert peso to rub, amount 12
Converted peso to rub, amount 12, Result {ok,36}
{ok,36}
    11> caseconverter:to_rub2({yene,12}).
Can't convert to rub, error {yene,12}
Converted yene to rub, amount 12, Result {error,badarg}
{error,badarg}
    12> caseconverter:to_rub3({yene,12}).
Can't convert to rub, error {yene,12}
{error,badarg}
    13> caseconverter:to_rub2({euro,-15}).
Can't convert to rub, error {euro,-15}
Converted euro to rub, amount -15, Result {error,badarg}
{error,badarg}
    14> caseconverter:to_rub3({euro,-15}).
Can't convert to rub, error {euro,-15}
{error,badarg}

        %% В целом в основном отличие с записью от без записи в переменную в том что где идет запись там нам известно больше по возвращенному результату, там указаны изначальные данные которые мы задали, а во втором ничего лишнего только нужный нам результат
%% Зажание 2 

    27> c("caseconverter.erl").
{ok,caseconverter}
    28> rr("convrec.hrl").
[conv_info]
    29> caseconverter:rec_to_rub(#conv_info{type=usd,amount=100,commission=0.01}).
{ok,7474.5}
    30> caseconverter:rec_to_rub(#conv_info{type=peso,amount=12,commission=0.02}).
{ok,35.28}
    31> caseconverter:rec_to_rub(#conv_info{type=yene,amount=30,commission=0.02}).
Error convertation to rub {conv_info,yene,30,0.02}
{error,badarg}
    32> caseconverter:rec_to_rub(#conv_info{type=euro,amount=-15,commission=0.02}).
Error convertation to rub {conv_info,euro,-15,0.02}
{error,badarg}

%% Задание 3

    12> recursion:tail_fac(5).
120
    13> recursion:tail_fac(0).
1
    14> recursion:duplicate([1,2,3,4,5]).
[1,1,2,2,3,3,4,4,5,5]
    15> recursion:tail_duplicate([]).
[]
    16> recursion:tail_duplicate([1,2,3,4,5]).
[1,1,2,2,3,3,4,4,5,5]
    17> recursion:tail_duplicate([]).
[]