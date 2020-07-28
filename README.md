Note: This repo is largely a snapshop record of bring Wikidata
information in line with Wikipedia, rather than code specifically
deisgned to be reused.

The code and queries etc here are unlikely to be updated as my process
evolves. Later repos will likely have progressively different approaches
and more elaborate tooling, as my habit is to try to improve at least
one part of the process each time around.

---------

Step 1: Check the Position Item
===============================

The Wikidata item — https://www.wikidata.org/wiki/Q3740505 —
contains all the data expected already.

Step 2: Tracking page
=====================

PositionHolderHistory did not exist. Initial version at
https://www.wikidata.org/w/index.php?title=Talk:Q3740505&oldid=1240648687
with 16 dated memberships, none undated; and 14 warnigs.

Step 3: Set up the metadata
===========================

The first step in the repo is always to edit [add_P39.js script](add_P39.js)
to configure the Item ID and source URL.

Step 4: Get local copy of Wikidata information
==============================================

    wd ee --dry add_P39.js | jq -r '.claims.P39.value' |
      xargs wd sparql office-holders.js | tee wikidata.json

Step 5: Scrape
==============

Comparison/source = https://en.wikipedia.org/wiki/List_of_mayors_of_Tallinn

    wb ee --dry add_P39.js  | jq -r '.claims.P39.references.P4656' |
      xargs bundle exec ruby scraper.rb | tee wikipedia.csv

For simplicity I only took the data from re-independence (Hardo Aasmäe)
onwards.

Step 6: Create missing P39s
===========================

    bundle exec ruby new-P39s.rb wikipedia.csv wikidata.json |
      wd ee --batch --summary "Add missing P39s, from $(wb ee --dry add_P39.js | jq -r '.claims.P39.references.P4656')"

No additions needed.

Step 7: Add missing qualifiers
==============================

    bundle exec ruby new-qualifiers.rb wikipedia.csv wikidata.json |
      wd aq --batch --summary "Add missing qualifiers, from $(wb ee --dry add_P39.js | jq -r '.claims.P39.references.P4656')"

1 addition made as https://tools.wmflabs.org/editgroups/b/wikibase-cli/5e4871316c6d1/

Step 8: Add date precision
==========================

    Q3741462$cb32a688-43f0-1747-e95d-0659b9f8eb6d P580 1990-01-01 1990-01
    Q3741462$cb32a688-43f0-1747-e95d-0659b9f8eb6d P582 1992-01-01 1992-04
    Q1676750$c406e2cf-48a9-c398-11c1-64b459f0fb52 P580 1992-01-01 1992-04
    Q1676750$c406e2cf-48a9-c398-11c1-64b459f0fb52 P582 1996-01-01 1996-10-31
    Q7346851$edea9445-4a82-2f61-eb33-63c3006e70ea P580 1996-11-01 1996-11-14
    Q11023034$9796d389-4037-6507-89e7-ade7eef16e2d P580 1997-01-01 1997-05
    Q11023034$9796d389-4037-6507-89e7-ade7eef16e2d P582 1999-01-01 1999-03
    Q6321970$8680a1f2-40d5-e4fa-ee76-cd53b26c5fa4 P580 1999-01-01 1999-11
    Q6321970$8680a1f2-40d5-e4fa-ee76-cd53b26c5fa4 P582 2001-01-01 2001-06
    Q355241$cae373e3-4155-2efc-1e28-f21dfec17f89 P582 2015-01-01 2015-09

Accept the suggested higher precision dates as:

    pbpaste | wd uq --batch --summary "Add higher precision dates from (wb ee --dry add_P39.js | jq -r '.claims.P39.references.P4656')"

-> https://tools.wmflabs.org/editgroups/b/wikibase-cli/679760d1b053f/


Step 9: Refresh the Tracking Page
==================================

New version at https://www.wikidata.org/w/index.php?title=Talk:Q3740505&oldid=1240666913
