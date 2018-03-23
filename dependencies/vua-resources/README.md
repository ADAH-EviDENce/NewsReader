# vua-resources
Lexical resources that are used for semantic parsing by various CLTL modules: OntoTagger, EventCoreference.

ili.ttl.gz
  GlobalWordnet InterLingual Index file

eurovoc:
    eurovoc_in_skos_core_concepts.rdf.gz
        RDF/SKOS hiearchy with concept labels
<rdf:Description rdf:about="http://eurovoc.europa.eu/4636">
<skos:prefLabel xml:lang="ga">Translation expected</skos:prefLabel>
<skos:prefLabel xml:lang="et">vaktsineerimine</skos:prefLabel>
<skos:prefLabel xml:lang="mk">вакцинација</skos:prefLabel>
<skos:prefLabel xml:lang="hu">vakcinálás</skos:prefLabel>
<skos:prefLabel xml:lang="mt">tilqima</skos:prefLabel>
<skos:prefLabel xml:lang="fi">rokotus</skos:prefLabel>
<skos:prefLabel xml:lang="de">Impfung</skos:prefLabel>
<skos:prefLabel xml:lang="nl">vaccinatie</skos:prefLabel>
<skos:prefLabel xml:lang="sk">očkovanie</skos:prefLabel>
<skos:prefLabel xml:lang="pl">szczepienie</skos:prefLabel>
<skos:prefLabel xml:lang="hr">cijepljenje</skos:prefLabel>
<skos:prefLabel xml:lang="lt">skiepijimas</skos:prefLabel>
<skos:prefLabel xml:lang="it">vaccinazione</skos:prefLabel>
<skos:prefLabel xml:lang="sl">cepljenje</skos:prefLabel>
<skos:prefLabel xml:lang="cs">očkování</skos:prefLabel>
<skos:prefLabel xml:lang="es">vacunación</skos:prefLabel>
<skos:prefLabel xml:lang="sq">vaksinim</skos:prefLabel>
<skos:prefLabel xml:lang="el">εμβολιασμός</skos:prefLabel>
<skos:prefLabel xml:lang="da">vaccination</skos:prefLabel>
<skos:prefLabel xml:lang="ro">vaccinare</skos:prefLabel>
<skos:prefLabel xml:lang="bg">ваксинация</skos:prefLabel>
<skos:prefLabel xml:lang="sv">vaccination</skos:prefLabel>
<skos:prefLabel xml:lang="sr">вакцинација</skos:prefLabel>
<skos:prefLabel xml:lang="fr">vaccination</skos:prefLabel>
<skos:prefLabel xml:lang="en">vaccination</skos:prefLabel>
<skos:prefLabel xml:lang="pt">vacinação</skos:prefLabel>
<skos:prefLabel xml:lang="lv">vakcinācija</skos:prefLabel>
<rdf:type rdf:resource="http://www.w3.org/2004/02/skos/core#Concept"/>
<skos:inScheme rdf:resource="http://eurovoc.europa.eu/100141"/>
<skos:inScheme rdf:resource="http://eurovoc.europa.eu/100215"/>
<skos:broader rdf:resource="http://eurovoc.europa.eu/1854"/>
<skos:related rdf:resource="http://eurovoc.europa.eu/4635"/>
<skos:altLabel xml:lang="et">kaitsepookimine</skos:altLabel>
<skos:altLabel xml:lang="nl">inenting</skos:altLabel>
<skos:altLabel xml:lang="lt">vakcinavimas</skos:altLabel>
<skos:altLabel xml:lang="it">vaccinoprofilassi</skos:altLabel>
<skos:altLabel xml:lang="cs">imunizace</skos:altLabel>
<skos:altLabel xml:lang="cs">vakcinace</skos:altLabel>
<skos:altLabel xml:lang="hr">vakcinacija</skos:altLabel>
<skos:altLabel xml:lang="mk">вакцинирање</skos:altLabel>
<skos:altLabel xml:lang="mk">имунизација</skos:altLabel>
</rdf:Description>

    eurovoc_skos.rdf.gz
        SKOS description of all concepts, no hiearchy

<rdf:Description rdf:about="http://eurovoc.europa.eu/156656">
<rdf:type rdf:resource="http://www.w3.org/2008/05/skos-xl#Label"/>
<owl:versionInfo rdf:datatype="http://www.w3.org/2001/XMLSchema#string">n/a</owl:versionInfo>
<isothes:status rdf:resource="http://publications.europa.eu/resource/authority/status/active"/>
<skosxl:literalForm xml:lang="da">musik</skosxl:literalForm>
<dct:type rdf:resource="http://publications.europa.eu/resource/authority/label-type/STANDARDLABEL"/>
</rdf:Description>

    euvoc.rdf
        RDF model/schema

    mapping_eurovoc_skos.csv.gz
        Eurovoc thesaurus labels with mapping to their label ids:
        kunstværk	da	http://eurovoc.europa.eu/156657
        Ablehnung eines Laienrichters	de	http://eurovoc.europa.eu/167730
        myöntämisilmoitus	fi	http://eurovoc.europa.eu/387218

    mapping_eurovoc_skos.label-id.concept.gz
        mapping from label id to concept id
        http://eurovoc.europa.eu/218249	http://eurovoc.europa.eu/6397
        http://eurovoc.europa.eu/214476	http://eurovoc.europa.eu/1373
        http://eurovoc.europa.eu/215929	http://eurovoc.europa.eu/5188

    mapping_eurovoc_skos.label.concept.gz
        mapping from label to concept
        vaccination	en	http://eurovoc.europa.eu/4636
        retired worker	en	http://eurovoc.europa.eu/3623
        Nordic Council countries	en	http://eurovoc.europa.eu/130
        Crete	en	http://eurovoc.europa.eu/305
        woman	en	http://eurovoc.europa.eu/5280

odwn_orbn_gwg-LMF_1.3.xml.gz
  Open Dutch wordnet in LMF format
  
PredicateMatrix.v1.3.txt.role.odwn.gz
  Predicate matrix for Open Dutch Wordnet
  
wneng-30.lmf.xml.xpos.gz
  English WordNet
  
Grammatical-words.en
  List of English grammatical words that should not be tagged with PredicateMatrix
Grammatical-words.nl
  List of Dutch grammatical words that should not be tagged with PredicateMatrix

contextual.txt, grammatical.txt, source.txt
  FrameNet Frames considered to refer to real-world events (contextuals), have not reference (grammatical) or introduce sources (source)
  
frAllRelation.xml
  Relations between FrameNet frames

frRelation.xml
  Subset of FrameNet frame relations to capture thematic relations only
  
wn3-ili-synonyms.txt
  Mapping of English synonyms to ILI concepts
  
ESO_Version2.owl
  Event & Situation Ontology
  
