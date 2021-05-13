#!/usr/bin/env -S swipl -q --stack_limit=8m
:- module(siglog, [siglog/1]).

:- [web].
:- [library(www_browser)].

siglog(start) :-
  serve,
  www_open_url("http://localhost:8080"),
  sleep(36000000000000).


siglog(private) :-
  serve,
  process_create(path('firefox'),['-private-window','http://localhost:8080'],[process(PID),detached(true)]),
  sleep(36000000000000).


siglog(compile) :-
  qsave_program(siglog,[ goal(siglog(start)), stand_alone(true), foreign(save), verbose(true)]),
  qsave_program('siglog-private',[ goal(siglog(private)), stand_alone(true), foreign(save), verbose(true)]).
