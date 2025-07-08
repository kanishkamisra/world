#!/bin/bash

## Run only if you are Kanishka Misra :P 

MEGA_DIR=../induction-nomodels/data

cp $MEGA_DIR/xcslb_compressed.csv data/

cp $MEGA_DIR/post_annotation_data/feature_metadata.csv data/

cp $MEGA_DIR/concept_senses.csv data/

cp $MEGA_DIR/concept_matrix.txt data/

cp $MEGA_DIR/post_annotation_data/post_annotation_all_full.csv data/xcslb.csv

python src/negate_and_pluralize.py

#python pluralize.py
