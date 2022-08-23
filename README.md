# world

Create mini-worlds consisting of concepts, their properties, their hierarchical organization, and ways to query for various related information.

This repo is in active development, so pls no judging code :face_in_clouds:	

## Requirements

All the following packages can be installed using `pip`

- semantic_memory*
- torch (> 1.8)
- nltk (3.7)
- numpy
- inflect
- pattern (optional, if you want to run `src/negate.py`)

*Note: run `pip install semantic-memory -U` just in case


## Key datasets

<!-- - Concept-feature data: `data/xcslb_compressed`
    - **Format:** `concept, feature, label, category`
- Concept feature data but in matrix form: `data/concept_matrix.txt`
- Concept Lexicon: `data/concept_senses.csv`
- Feature Metadata: `data/feature_lexicon.csv` -->

### Concept - Feature data

**File:** `data/xcslb_compressed.csv`

Fields:
- `concept`: noun concept
- `feature`: feature or property (verb-phrase)
- `label`: 1 if concept possesses property, 0 otherwise.
- `category`: category label as annotated by [Devereaux et al., 2014](https://link.springer.com/article/10.3758/s13428-013-0420-4)

Note that all labels are set to 1 since the dataset in the repo is in compressed form (long-form), widening it would mean that every concept-feature pair that is absent in the compressed form would be associated with the label 0.

### Concept - Feature Matrix

**File:** `data/concept_matrix.txt`

Rows = concepts, columns = individual features. Values = 1 if concept associated with feature, 0 otherwise.

### Concept Lexicon

**File:** `data/concept_senses.csv`

Fields:
- `category`: category label as annotated by [Devereaux et al., 2014](https://link.springer.com/article/10.3758/s13428-013-0420-4)
- `concept`: noun concept
- `sensekey`: Sense key in WordNET (to connect to a taxonomy)
- `article`: Article assignment of the noun (a/an/nothing).

### Feature Lexicon

**File:** `data/feature_lexicon.csv`

Fields:
- `feature`: feature or property (verb-phrase)
- `feature_type`: Type of feature, as annotated by [Devereaux et al., 2014](https://link.springer.com/article/10.3758/s13428-013-0420-4). One of `{taxonomic, encyclopedic, functional, visual perceptual, other perceptual}`.
- `negation`: Negated verb-phrase of the property. Generated by running `python negate.py` in `src/`.


## Using `semantic-memory` to generate worlds

Start off by running `pip install semantic_memory`, then follow along:

### Creating a mini-world

```py
from semantic_memory import memory

world = memory.Memory(
    concept_path="../data/concept_senses.csv",
    feature_path="../data/xcslb_compressed.csv",
    matrix_path="../data/concept_matrix.txt",
    feature_metadata="../data/feature_lexicon.csv",
)
world.create()
```

### Get category members

Each world consists of a taxonomic organization of knowledge, which can be 
queried by using wordnet lemma names (e.g., *animal* = `animal.n.01`):

```py
print(world.taxonomy['animal.n.01'])

# OUTPUT:
# Node animal.n.01
# Parent:organism.n.01
# Children: ['chordate.n.01', 'young.n.01', 'invertebrate.n.01', 'larva.n.01']

```
In most cases, the leaf nodes for every higher-order category are the main concepts in the dataset.

To get all birds (i.e., leaf nodes of the `bird.n.01` category):
```py
birds = world.taxonomy['bird.n.01'].descendants()
print(len(birds))

# OUTPUT:
# 36

print(birds[:5])

# OUTPUT:
# ['budgie', 'parakeet', 'buzzard', 'falcon', 'hawk']
```

### Generating generics

Instructions for generating generics can be found in the demo notebook, [`src/Generics.ipynb`](src/Generics.ipynb).

### TODO: exploring features, compute similarity, etc.


## Citation

If you use the dataset and the tools used in this repository, please cite the following paper:
```bibtex
@inproceedings{misra2022property,
  title={A Property Induction Framework for Neural Language Models},
  author={Kanishka Misra and Julia Rayz and Allyson Ettinger},
  booktitle={Proceedings of the 44th Annual Conference of the Cognitive Science
Society},
  year={2022}
}
```