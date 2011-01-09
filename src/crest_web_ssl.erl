%% Copyright (c) 2010 Alessandro Sivieri <alessandro.sivieri@mail.polimi.it>
%% 
%% This file is part of CREST-Erlang.
%% 
%% CREST-Erlang is free software: you can redistribute it and/or modify
%% it under the terms of the GNU Lesser General Public License as published by
%% the Free Software Foundation, either version 3 of the License, or
%% (at your option) any later version.
%% 
%% CREST-Erlang is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU Lesser General Public License for more details.
%% 
%% You should have received a copy of the GNU Lesser General Public License
%% along with CREST-Erlang. If not, see <http://www.gnu.org/licenses/>.
%% 
%% @author Alessandro Sivieri <alessandro.sivieri@mail.polimi.it>
%% @doc Web server for crest, with SSL support.
%% Autogenerated by MochiWeb.
%% @copyright 2010 Alessandro Sivieri

-module(crest_web_ssl).
-export([start/1, stop/0, loop/2]).

%% External API

%% @doc Start the Web server.
%% @spec start([any()]) -> ok
start(Options) ->
    {DocRoot, Options1} = get_option(docroot, Options),
    Loop = fun (Req) ->
                   ?MODULE:loop(Req, DocRoot)
           end,
    mochiweb_http:start([{name, ?MODULE}, {loop, Loop} | Options1]).

%% @doc Stop the Web server.
%% @spec stop() -> ok
stop() ->
    mochiweb_http:stop(?MODULE).

%% @doc Main server loop, serving requests.
%% @spec loop(request(), string()) -> any()
loop(Req, _DocRoot) ->
    "/" ++ Path = Req:get(path),
    log4erl:info("Request (SSL): ~p~n", [Path]),
	case Req:get(method) of
        Method when Method =:= 'GET'; Method =:= 'HEAD' ->
            case string:tokens(Path, "/") of
                _ ->
                    Req:respond({404, [], []})
            end;
        'POST' ->
            case string:tokens(Path, "/") of
                ["crest", "spawn"] ->
					Key = crest_peer:spawn_install(Req:parse_post()),
                    Req:respond({200, [{"Content-Type", "application/json"}], [mochijson2:encode(crest_utils:pack_key(Key))]});
				["crest", "remote"] ->
					case crest_peer:remote(Req:parse_post()) of
                        {ok, {CT, Message}} ->
                            Req:respond({200, [{"Content-Type", CT}], [Message]});
                        {error} ->
                            Req:respond({404, [], []})
                    end;
                _ ->
                    Req:respond({404, [], []})
            end;
        _ ->
            Req:respond({501, [], []})
    end.

%% Internal API

get_option(Option, Options) ->
    {proplists:get_value(Option, Options), proplists:delete(Option, Options)}.
