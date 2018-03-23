VUA SRL Dutch additional roles
==============

Description
------------
This is an SRL postfix hack that adds semantic roles for nominal events that were added to the predicate layer after the regular SRL module was run. It only creates roles for PPs that follow the nominal event.

Revisions version 2: 

1. Program no longer uses the identifier to determine whether the predicate is nominal. Instead it:
- takes predicates that do not have any roles yet (otherwise it must be a verbal predicate)
- checks whether head of constituent is noun

2. The program no longer output 'extra-role' as semantic role label, but:
- if head of PP is 'van' -> arg1
- else: argM (underspecified modifier)


Prerequisites
-----------
[KafNafParserPy](https://github.com/cltl/KafNafParserPy "KafNafParserPy")

Usage
--------
cat input.naf | python vua-srl-dutch-additional-roles.py

Contact
-------
Questions version 2:

Antske Fokkens
antske.fokkens@vu.nl
Vrije Universiteit Amsterdam

Questions version 1:

Marieke van Erp
marieke.van.erp@vu.nl
VU University Amsterdam

License
----------
Apache v2. See LICENSE file for details. 
