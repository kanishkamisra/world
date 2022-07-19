library(tidyverse)
library(text2vec)
library(factoextra)

features <- read_csv('data/xcslb.csv')

animal_features <- features %>%
  filter(category %in% c("land animal", "sea creature", "fish", "invertebrate", "bird"), label == 1) %>%
  distinct(feature) %>%
  pull(feature)

features %>%
  filter(feature %in% animal_features) %>%
  select(feature, concept, label) %>%
  pivot_wider(names_from = concept, values_from = label, values_fill = 0) %>%
  column_to_rownames(var = "feature") %>%
  as.matrix() %>%
  Matrix::Matrix(sparse = TRUE) %>%
  sim2(method = "jaccard", norm = "none") %>%
  as.matrix() %>%
  as.data.frame() %>%
  rownames_to_column("property1") %>%
  as_tibble() %>%
  pivot_longer(names_to = "property2", values_to = "sim", cols = -c("property1")) %>%
  View()

concept_matrix <- features %>%
  select(feature, concept, label) %>%
  pivot_wider(names_from = feature, values_from = label, values_fill = 0) %>%
  column_to_rownames(var = "concept") %>%
  as.matrix()

pairwise_sims <- concept_matrix %>%
  Matrix::Matrix(sparse = TRUE) %>%
  sim2(method = "jaccard", norm = "none") %>%
  as.matrix() %>%
  as.data.frame() %>%
  rownames_to_column("concept1") %>%
  as_tibble() %>%
  pivot_longer(names_to = "concept2", values_to = "sim", cols = -c("concept1"))

ensquare <- function(x) {
  x %>%
    select(concept1, concept2, dist) %>%
    pivot_wider(names_from = concept2, values_from = dist) %>%
    column_to_rownames("concept1") %>%
    as.matrix()
}

h_clust <- pairwise_sims %>%
  # filter(category1 %in% CATEGORIES, category2 %in% CATEGORIES) %>%
  mutate(dist = 1-sim) %>%
  ensquare() %>%
  as.dist() %>%
  hclust()

h_clust$

h_clust %>% fviz_dend(k = 12,   
                         # cex = 0.5, 
                         rect = TRUE, 
                         rect_fill = TRUE, 
                         horiz = FALSE,
                         palette = "jco", 
                         rect_border = "jco", 
                         color_labels_by_k = TRUE) + 
  theme_void() + 
  theme(plot.margin = unit(rep(0.7, 4), "cm"))
