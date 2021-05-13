:- module(signal, [signal/2]).

:- [library(http/json),
    library(http/http_open)].

% todo: daemon, dbus interface?
% https://github.com/AsamK/signal-cli/wiki/Quickstart
% https://github.com/AsamK/signal-cli/blob/master/man/signal-cli.1.adoc

% interface to signal-cli

signal(cli(Username,Command),Response) :-
  signal(cli(Username,Command,[]),Response).

signal(cli(Username,Command,Options),Response) :-
  process_create(
    path('signal-cli'),
    ['-u',Username,Command|Options],
    [stdout(pipe(Out_stream)),stderr(pipe(Err_stream))]),
  read_string(Out_stream,_,Out_string),
  read_string(Err_stream,_,Err_string),
  Response = [out(Out_string), err(Err_string)].

% run signal desktop

signal(desktop,PID) :-
  process_create(path('signal-desktop'),[],[process(PID),detached(true)]).

% View user info

signal(user,User) :-
  expand_file_name('~/.local/share/signal-cli/data/*',Phone_number_files),
  member(Phone_number_file,Phone_number_files),
  exists_file(Phone_number_file),
  open(Phone_number_file, read, JSON),
  json_read(JSON,json(User),[true(true),false(false)]).

signal(username,Username) :-
  signal(user,User),
  member(username=Username,User).

signal(registered_username,Username) :-
  signal(user,User),
  member(username=Username,User),
  member(registered=true,User).

% Messages

%signal(receive,Messages) :-
%  signal(cli(receive),Response,['-o',json,'-u',Username]),
%  atom_json_term(Response,json(Messages),[]).

% Installation

signal(install,Bin):-
  http_open("https://api.github.com/repos/AsamK/signal-cli/releases/latest",Stream,[]),
  json_read(Stream,json(Latest)),
  member((assets=Assets),Latest),
  member(json(Application),Assets),
  member(browser_download_url=URL,Application),
  process_create(path(curl),['-L','-#',URL],[stdout(pipe(Data))]),
  process_create(path(tar),[zxf,'-','-C','/opt'],[stdin(stream(Data))]),
  expand_file_name('/opt/signal-cli-*/bin/signal-cli',Bins),
  last(Bins,Bin),
  process_create(path(ln),['-sf',Bin,'/usr/local/bin'],[]).

