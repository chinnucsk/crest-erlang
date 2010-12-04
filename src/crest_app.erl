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
%% @doc CREST application behaviour: it starts and stop the application.
%% Autogenerated by MochiWeb.
%% @copyright 2010 Alessandro Sivieri

-module(crest_app).
-behaviour(application).
-export([start/2,stop/1]).

%% External API

%% @doc Start all dependency modules and the CREST application
%% @spec start(atom(), [string()]) -> ok
start(_Type, _StartArgs) ->
    crest_deps:ensure(),
    crest_sup:start_link().

%% @doc Stop the application
%% @spec stop(atom()) -> ok
stop(_State) ->
    ok.
