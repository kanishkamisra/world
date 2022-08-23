library(tidyverse)
library(widyr)
# Q. How do we get the global features of a bird if
# all we have is the feature of its subordinates?
# Idea: features that are perfectly correlated!

feature_metadata <- read_csv("data/feature_metadata.csv")
feature_metadata %>%
  filter(feature_type == "taxonomic")

xcslb <- read_csv("data/xcslb_compressed.csv")

indiv <- xcslb %>%
  select(concept, feature, label) %>%
  count(feature, sort = TRUE) %>%
  mutate(p = n / sum(n))

co_occ <- xcslb %>%
  select(concept, feature, label) %>%
  pairwise_count(feature, concept, diag = TRUE, sort = TRUE) %>%
  rename(pairwise_n = n)

statistical_entailment <- co_occ %>%
  rename(feature1 = item1, feature2 = item2) %>%
  left_join(indiv %>%
              select(feature1 = feature, n_f1 = n),
            by = "feature1") %>%
  mutate(entailment = pairwise_n/n_f1)

statistical_entailment %>%
  filter(entailment == 1.0, feature1 != feature2)

# Should we compare entailment = 1 with perfectly uncorrelated features?
# maybe we can target a gradient, and for now generate predictions for all
# features, and post-process. Seems a bit excessive though. But good enough for now.
  
