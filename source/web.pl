:- module(web, [serve/0]).

% todo: redir to homescreen w/o err
% show stdout messages

:- [library(http/thread_httpd),
    library(http/http_dispatch),
    library(http/http_header),
    library(http/html_head),
    library(http/html_write),
    library(http/http_wrapper),
    library(http/http_parameters),
    library(www_browser)].

:- [signal].
:- [style].

:- http_handler(root(.), root_handler, []).
:- http_handler(root(register),register_handler,[]).
:- http_handler(root(verify),verify_handler,[]).
:- http_handler(root(update_profile),update_profile_handler,[]).
:- http_handler(root(send),send_handler,[]).
:- http_handler(root(join_group),join_group_handler,[]).
:- http_handler(root(link),link_handler,[]).

:- http_handler(root('style.css'),style_handler,[]).

user:file_search_path(static, static).
:- http_handler(root(.), serve_files_in_directory(static), [prefix]).


localhost('127.0.0.1').
localhost(localhost).

message_menu -->
  html(details([
    summary('messages'),
    \send_form])).

send_form -->
  html(fieldset([
    legend(send),
    form([action(send),method(post)],[
      % recipientS in plural?
      div(label([div(from),\registered_username_select])),
      div(label([div(to),input([name(recipient),type(tel),placeholder('+0000000000')])])),
      div(textarea(name(message),[])),
      input([type(submit),value(send)])])])).

href_list([]) -->
  [].

href_list([Href|Rest]) -->
  html([
    li(a(href(Href),Href)),
    \href_list(Rest)]).

options([]) -->
  [].

options([Option|Rest]) -->
  html([
    option(value(Option),Option),
    \options(Rest)]).


username_select -->
  { findall(
    Username,
    signal(username, Username),
    Usernames) },
  html(select(name(username),\options(Usernames))).

registered_username_select -->
  { findall(
    Username,
    signal(registered_username, Username),
    Usernames) },
  html(select(name(username),\options(Usernames))).

user_menu -->
  html(details([
    summary('profile'),
    \register_form,
    \verify_form,
    \update_profile_form
    ])).

register_form -->
  html(fieldset([
    legend('register a new number'),
    form([action(register),method(post)],[
      div(input([name(username),placeholder('+0000000000'),type(tel)])),
      input([type(submit),value('register')])])])).

verify_form -->
  html(fieldset([
    legend('verify the received code'),
    form([action(verify),method(post)],[
      div(\username_select),
      div(input([name(code),placeholder('0000')])),
      input([type(submit),value('verify')])])])).

update_profile_form -->
  html(fieldset([
    legend('add your details'),
    form([action(update_profile),method(post)],[
      div(\registered_username_select),
      div(input([name(name),placeholder('my name')])),
      input([type(submit),value('update profile')])])])).

contacts_menu -->
  html(details([
    summary('contacts'),
    \join_group_form
    ])).

join_group_form -->
  html(fieldset([
    legend('join group'),
    form([action(join_group),method(post)],[
      div(\registered_username_select),
      div(label([
        div('invitation link'),
        input([name(uri),placeholder('https://signal.group/#')])])),
      input([type(submit),value('join group')])])])).

link_menu -->
  html(details([
    summary('linking other devices'),
    p("sorry, not yet available.")
    ])).

about_menu -->
  html(details([
    summary('about'),
    p("this is shartphone. free/libre software for using signal without a smartphone. built on top of signal-cli using swi-prolog.")
    ])).

root_handler(Request) :-
%   signal(cli('-v'),Latest),
  http_peer(Request,IP),
  % only accept connections from localhost
  localhost(IP),
  http_parameters(
    Request,
    [err(Err, [default("")])]),
  reply_html_page([title(shartphone), link([rel(stylesheet),href('/style.css')])],
    [
    center(h1(shartphone)),
    pre(Err),
    p(\user_menu),
    p(\message_menu),
    p(\contacts_menu),
    p(\link_menu),
    p(\about_menu)
    ]).

root_handler(_Request):-
  throw(http_reply(forbidden('shartphone'))).


register_handler(Request) :-
  http_parameters(
    Request,
    [username(Username, [])]),
  signal(cli(Username, register), Response),
  member(err(Err),Response),
  http_link_to_id(root_handler, [err(Err)], Then),
  http_redirect(see_other, Then, Request).

verify_handler(Request) :-
  http_parameters(
    Request,
    [username(Username, []),
     code(Code, [])]),
  signal(cli(Username, verify, [Code]), Response),
  member(err(Err),Response),
  http_link_to_id(root_handler, [err(Err)], Then),
  http_redirect(see_other, Then, Request).

update_profile_handler(Request) :-
  http_parameters(
    Request,
    [username(Username, []),
     name(Name, [])]),
  signal(cli(Username, updateProfile, ['--name', Name]), Response),
  % if err, then show error
  member(err(Err),Response),
  http_link_to_id(root_handler, [err(Err)], Then),
  http_redirect(see_other, Then, Request).

send_handler(Request) :-
  http_parameters(
    Request,
    [username(Username,[]),
     recipient(Recipient,[]),
     message(Message,[])]),
  signal(cli(Username, send, [Recipient, '-m', Message]), Response),
  member(err(Err),Response),
  http_link_to_id(root_handler, [err(Err)], Then),
  http_redirect(see_other, Then, Request).

join_group_handler(Request) :-
  http_parameters(
    Request,
    [username(Username,[]),
     uri(URI,[])]),
  signal(cli(Username, joinGroup, ['--uri', URI]), Response),
  member(err(Err),Response),
  http_link_to_id(root_handler, [err(Err)], Then),
  http_redirect(see_other, Then, Request).

style_handler(_Request) :-
  style(shartphone,Style),
  format('Content-type: text/css~n~n'),
  format(Style).

serve() :-
  http_server(http_dispatch, [port(8080)]).
