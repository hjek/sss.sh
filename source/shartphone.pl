#!/usr/bin/env -S swipl -q --stack_limit=8m
:- module(shartphone, [shartphone/1]).

:- [web].
:- [library(www_browser)].

shartphone(start) :-
  serve,
  www_open_url("http://localhost:8080"),
  sleep(36000000000000).


shartphone(private) :-
  serve,
  process_create(path('firefox'),['-private-window','http://localhost:8080'],[process(PID),detached(true)]),
  sleep(36000000000000).


shartphone(compile) :-
  qsave_program(shartphone,[ goal(shartphone(start)), stand_alone(true), foreign(save), verbose(true)]),
  qsave_program('shartphone-private',[ goal(shartphone(private)), stand_alone(true), foreign(save), verbose(true)]).
