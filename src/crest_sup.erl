%% Copyright (c) 2010,2011 Alessandro Sivieri <sivieri@elet.polimi.it>
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
%% @author Alessandro Sivieri <sivieri@elet.polimi.it>
%% @doc Supervisor for the crest application.
%% Autogenerated by MochiWeb.
%% @copyright 2010,2011 Alessandro Sivieri

-module(crest_sup).
-behaviour(supervisor).
-export([start_link/0, upgrade/0]).
-export([init/1]).

%% External API

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

upgrade() ->
    {ok, {_, Specs}} = init([]),

    Old = sets:from_list(
            [Name || {Name, _, _, _} <- supervisor:which_children(?MODULE)]),
    New = sets:from_list([Name || {Name, _, _, _, _, _} <- Specs]),
    Kill = sets:subtract(Old, New),

    sets:fold(fun (Id, ok) ->
                      supervisor:terminate_child(?MODULE, Id),
                      supervisor:delete_child(?MODULE, Id),
                      ok
              end, ok, Kill),

    [supervisor:start_child(?MODULE, Spec) || Spec <- Specs],
    ok.

init([]) ->
	Filename = crest_deps:local_path(["config", "web.config"]),
	case file:consult(Filename) of
		{ok, PortList} ->
			{web, WebPort} = lists:keyfind(web, 1, PortList),
			{web_ssl, WebSSLPort} = lists:keyfind(web_ssl, 1, PortList);
		{error, Reason} ->
			log4erl:info("Unable to load web configuration: ~p~n", [Reason]),
			WebPort = 8080,
			WebSSLPort = 8443
	end,
    Ip = case os:getenv("MOCHIWEB_IP") of false -> "0.0.0.0"; Any -> Any end,   
    WebConfig = [
				 {max, 1000000},
         		 {ip, Ip},
                 {port, WebPort},
                 {docroot, crest_deps:local_path(["priv", "www"])}],
    Web = {crest_web,
           {crest_web, start, [WebConfig]},
           permanent, 5000, worker, dynamic},
	WebConfigSSL = [
			     {max, 1000000},
                 {ip, Ip},
                 {port, WebSSLPort},
                 {docroot, crest_deps:local_path(["priv", "www"])},
                 {ssl, true},
                 {ssl_opts, [
                    {certfile, crest_deps:local_path(["ca", "certs", "01.pem"])},
                    {keyfile, crest_deps:local_path(["ca", "private", "crest.key"])},
                    {verify, verify_peer},
                    {cacertfile, crest_deps:local_path(["ca", "cacert.pem"])},
                    {fail_if_no_peer_cert, true},
                    {verify_fun, fun(_) -> false end}
                 ]}],
    WebSSL = {crest_web_ssl,
           {crest_web_ssl, start, [WebConfigSSL]},
           permanent, 5000, worker, dynamic},
    Peer = {crest_peer,
            {crest_peer, start, []},
            permanent, 5000, worker, [crest_peer]},
	Router = {crest_local,
			  {crest_local, start, []},
			  permanent, 5000, worker, [crest_local]},
	SpawnSup = {crest_spawn_sup,
				{crest_spawn_sup, start_link, []},
				permanent, 5000, supervisor, [crest_spawn_sup]},

    Processes = [SpawnSup, Web, WebSSL, Peer, Router],
    {ok, {{one_for_one, 10, 10}, Processes}}.

%% Internal API

