#!/usr/bin/python

# This script takes a NAF file that contains a semantic role layer with nominal predicates
# and creates roles for PPs that follow it
# This is a hack for the Dutch NWR processing pipeline to improve event coverage

# Author version 1: Marieke van Erp  marieke.van.erp@vu.nl
# Date: 2 June 2015

# Author version 2 updates: Antske Fokkens antske.fokkens@vu.nl
# Date update: 12 December 2015

import sys
from KafNafParserPy import *
import datetime 

# Read input NAF file
input = sys.stdin
my_parser = KafNafParser(input)

## Create header info
lp = Clp()
lp.set_name('vua-srl-dutch-additional-roles-for-nominal-predicates')
lp.set_version('2.0')
lp.set_timestamp()

# revision version 2.0: module indication must be added to existing srl layer.
my_parser.add_linguistic_processor('srl', lp)

# Create an index of the role ids
role_index = 0
for pred in my_parser.get_predicates():
    for role in pred.get_roles():
        #FIXME: assumes roles are of form `r1' (currently standard)
        role_number = role.get_id()[1:]
        if int(role_number) > role_index:
                role_index = int(role_number)


depextractor = my_parser.get_dependency_extractor()
deps = depextractor.relations_for_term

# Extract nominal predicates from SRL layer
for pred in my_parser.get_predicates():
    #revision version 2: check if the predicate has any roles
    if len(pred.node.findall('role')) == 0:
        #retrieve the predicate's span
    
        for span_obj in pred.get_span(): 
            term_id = span_obj.get_id()
            term = my_parser.get_term(term_id)
            
            #Version 2 changes:
            #1. double check if we're dealing with a nominal predicate
            #2. go through dependencies and create roles for all that are pp dependencies
            #3. if head is 'van' dependency is arg1, else it is argM
            if term.get_pos() == 'noun':
                #check modifiers of the noun
                if term_id in deps:
                    for dep in deps.get(term_id):
                        if 'hd/mod' in dep[0]:
                            modterm = my_parser.get_term(dep[1])
                            if modterm.get_pos() == 'prep':
                                if modterm.get_lemma() == 'van':
                                    my_role = 'Arg1'
                                else:
                                    my_role = 'ArgM'
                                new_role = Crole()
                                role_index += 1
                                new_role.set_id('r' + str(role_index))
                                new_role.set_sem_role(my_role)
                                role_span = Cspan()
                                #target should be preposition and all its dependents (up to the edges of graph)
                                relations = [dep[1]]
                                relations = depextractor.get_full_dependents(dep[1], relations)
                                myrelations = set(relations)
                                #create target consisting of identified terms
                                for termid in sorted(myrelations):
                                    new_target = Ctarget()
                                    new_target.set_id(termid)
                                    role_span.add_target(new_target)
                                    
                                new_role.set_span(role_span)
                                pred.add_role(new_role)


# output NAF
my_parser.dump()