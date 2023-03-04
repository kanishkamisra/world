import csv
import inflect
import re
import spacy

from tqdm import tqdm

from pattern.en import conjugate

nlp = spacy.load("en_core_web_sm")
engine = inflect.engine()


def pluralize(phrase: str):
    """Converts a singular-noun expecting VP to a plural noun-expecting one."""
    modified = "it " + phrase
    doc = nlp(modified)
    first_verb = None
    for token in doc:
        if token.pos_ in ("AUX", "VERB"):
            first_verb = token
            break
    if first_verb is None:
        pluralized = first_verb.text
    else:
        pluralized = engine.plural_verb(first_verb.text)

    return pluralized + " " + doc[first_verb.i + 1 :].text.strip()


# weird behavior of pattern.en conjugate, don't ask.
try:
    warmup = conjugate("produces", "1sg")
except:
    pass
    # print("Warmup Complete!")

feature_metadata = []
with open("data/feature_metadata.csv", "r") as f:
    reader = csv.DictReader(f)
    for line in reader:
        feature_metadata.append(line)

fixed_negations = {
    "is": "is not",
    "has": "does not have",
    "can": "cannot",
    "was": "was not",
    "are": "are not",
    "uses": "does not use",
}


def get_first_verb(sentence):
    doc = nlp(sentence)
    verbs = [(token.text, token.tag_) for token in doc if token.pos_ in ["VERB", "AUX"]]
    try:
        verb, tag = verbs[0]
    except:
        # verb = None
        print(f"Verb not found in {sentence}!")

    return verb, tag


def negate_first_verb(verb, tag):
    if verb in fixed_negations.keys():
        replacement = fixed_negations[verb]
    else:
        if tag == "VBZ":
            conjugated = conjugate(verb, "1sg")
            replacement = f"does not {conjugated}"

    return replacement


def negate(phrase):
    sentence = f"It {phrase}."
    if "used to have" in phrase:
        first_verb = "used to have"  # ik, ik, cringe to call it a verb.
        negated = "did not have"
    elif phrase.startswith("uses "):
        first_verb = "uses"
        negated = "does not use"
    else:
        first_verb, first_verb_tag = get_first_verb(sentence)
        if first_verb == "contain":
            negated = "does not contain"
        else:
            negated = negate_first_verb(first_verb, first_verb_tag)

    return re.sub(rf"\b{first_verb}\b", f"{negated}", phrase)


with open("data/feature_lexicon.csv", "w") as f:
    writer = csv.writer(f)
    writer.writerow(["feature", "feature_type", "negation", "pluralized"])
    for line in tqdm(feature_metadata):
        feature = line["phrase"]
        feature_type = line["feature_type"]
        negation = negate(feature)
        pluralized = pluralize(feature)
        writer.writerow([feature, feature_type, negation, pluralized])
