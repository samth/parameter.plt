#lang scribble/doc

@begin[(require scribble/manual)
       (require scribble/eval)
       (require scribble/basic)
       (require (for-label "main.ss" racket/base))]

@title[#:tag "top"]{Parameter Utilities}

by Dave Herman (@tt{dherman at ccs dot neu dot edu}) and Sam Tobin-Hochstadt.

This library provides several utilities for @tech{parameter}s.

@section[#:tag "started"]{Getting Started}

Everything in this library is exported by a single module:

@defmodule[parameter]

@section[#:tag "pseudo"]{Pseudo-Parameters}
@declare-exporting[parameter]
A @deftech{pseudo-parameter} is like a Racket @tech{parameter}, but comprises both
an accessor and a mutator function. This can be used, for example, to create compound
parameters that simultaneously update multiple parameters.

@defproc[(make-pseudo-parameter (getter (-> _a)) (setter (_a -> any))) (pseudo-parameter/c _a)]{
Constructs a new @tech{pseudo-parameter} with @scheme[getter] and @scheme[setter] functions.}

@defproc[(pseudo-parameter? (x any)) boolean?]{
Determines whether a given value is a @tech{pseudo-parameter}.}

@defproc[(pseudo-parameter/c (c contract?)) contract?]{
A contract constructor for pseudo-parameters with an underlying value of contract @scheme[c].}

@section[#:tag "sets"]{Parameter Sets}
@declare-exporting[parameter]

A @deftech{parameter set} is a collection of Racket @tech{parameter}s that
can be read or written to all at once with a @tech{prefab} structure. Because the
structure is @tech{prefab}, a parameter set can also easily be marshalled and
demarshalled (assuming its values are all @scheme[write]able, of course).

@defform/subs[(define-parameter-set struct-id pseudo-id
                (param-id default-expr maybe-guard) ...)
              ([maybe-guard code:blank
                            (code:line guard-expr)])]{
Defines a @tech{parameter set}. The @scheme[struct-id] is defined as a @tech{prefab} structure
type with one field for each parameter in the set, in declaration order. The @scheme[pseudo-id]
is defined as a @tech{pseudo-parameter} that reads or writes the values of all the parameters
in the set simultaneously. Each @scheme[param-id] is defined as a parameter with default value
computed by @scheme[default-expr] and optional guard computed by @scheme[maybe-guard].}
