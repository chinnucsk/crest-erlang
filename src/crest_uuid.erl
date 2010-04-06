%% @author Alessandro Sivieri <alessandro.sivieri@mail.polimi.it>
%% @copyright 2010 Alessandro Sivieri
%% @doc Calculates a unique random UUID
%%      Based on a work by Travis Vachon
  
-module(crest_uuid).
-export([uuid/0]).
-import(random).

%% External API
uuid() ->
    to_string(v4()).

%% Internal API
v4() ->
    R1 = random:uniform(round(math:pow(2, 48))) - 1,
    R2 = random:uniform(round(math:pow(2, 12))) - 1,
    R3 = random:uniform(round(math:pow(2, 32))) - 1,
    R4 = random:uniform(round(math:pow(2, 30))) - 1,
    <<R1:48, 4:4, R2:12, 2:2, R3:32, R4: 30>>.

to_string(U) ->
    lists:flatten(io_lib:format("~8.16.0b-~4.16.0b-~4.16.0b-~2.16.0b~2.16.0b-~12.16.0b", get_parts(U))).

get_parts(<<TL:32, TM:16, THV:16, CSR:8, CSL:8, N:48>>) ->
    [TL, TM, THV, CSR, CSL, N].