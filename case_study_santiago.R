# =============================================================================
# Case study — Inter-municipal governance in Chile's Santiago Metropolitan
# Region, described with `netmem`
#
# Companion script for the netmem workshop at the LACSUG Conference
# (Latin American Network on Subnational Governance) — https://lansug.org
#
# The data and research question come from:
#
#   Arias-Yurisch, K., Retamal-Soto, K., Ramos-Fuenzalida, C., &
#   Espinosa-Rada, A. (2024). Participation in multiple policy venues in
#   governance of Chile's Santiago Metropolitan Region: When institutional
#   attributes can make the difference. Policy Studies Journal, 52(3), 583-602.
#   https://doi.org/10.1111/psj.12527
#
# The paper models these networks with ERGMs. Here we stay *descriptive*: we
# use netmem to characterise the same networks before any model is fitted, and
# show how netmem's matrix-first tools map onto the paper's central idea —
# that local governments participate in MULTIPLE, overlapping POLICY VENUES
# (the "ecology of games" framework), and that institutional attributes of
# those venues shape who collaborates with whom.
#
# Three inter-municipal policy venues among the 52 municipalities of Santiago:
#   * Inter-municipal AGREEMENTS  (self-organised; the paper's dependent net)
#   * Municipal ASSOCIATIONS      (self-organised; co-membership)
#   * Provincial FORUMS           (mandated; co-membership = same province)
# plus two contextual covariates: geographic ADJACENCY and road DISTANCE.
# =============================================================================

## ---------------------------------------------------------------------------
## 0. Setup
## ---------------------------------------------------------------------------
# install.packages(c("netmem", "openxlsx", "igraph"))
library(netmem)    # the star of the show: network measures from matrices
library(openxlsx)  # read the .xlsx data files
library(igraph)    # drawing only

packageVersion("netmem")

## ---------------------------------------------------------------------------
## 1. Load the data
## ---------------------------------------------------------------------------
load("santiago_metro.rda")
str(santiago_metro, max.level = 1)

AGR   <- santiago_metro$agreements    # inter-municipal agreements (DV in the paper)
ASSOC <- santiago_metro$associations  # shared municipal association (self-organised)
NEIGH <- santiago_metro$neighbours    # geographic adjacency
DIST  <- santiago_metro$distance      # road distance (km)
labs  <- rownames(AGR)                # 52 municipality abbreviations

# node attributes (2016 wave): a numeric matrix, one column per variable
att   <- santiago_metro$attributes
name  <- santiago_metro$municipality  # full names, for readable output
prov  <- att[, "province"]            # 1 Melipilla ... 6 Santiago
party <- att[, "party_right"]         # mayor's coalition: 1 right, 0 other
rural <- att[, "rural"]               # 1 rural, 0 urban
prof  <- att[, "professional"]        # professionalisation of municipal staff

# a pretty-print helper: show top-k nodes of a score with their full names
top_named <- function(x, k = 6) {
  o <- order(x, decreasing = TRUE)[1:k]
  setNames(round(x[o], 3), name[o])
}

## ---------------------------------------------------------------------------
## 2. Is the matrix what we think it is?  matrix_report()
## ---------------------------------------------------------------------------
# Always sanity-check before measuring: square? symmetric? binary? loops?
matrix_report(AGR)   # 52 x 52, symmetric (undirected), 119 agreements

## ---------------------------------------------------------------------------
## 3. The inter-municipal AGREEMENTS network — basic structure
## ---------------------------------------------------------------------------
# How much of the metropolis actually collaborates? (the network is undirected)
gen_density(AGR, directed = FALSE)            # ~0.09: a sparse governance web

# Who are the brokers? Degree = number of partner municipalities.
deg <- gen_degree(AGR, digraph = FALSE)
sort(deg, decreasing = TRUE)[1:6]                 # top 6 municipalities by degree
top_named(deg)                                # the wealthy eastern comunas lead

# Fragmentation: one giant component plus a handful of isolated municipalities.
comp <- components_id(AGR)
comp$size                                     # sizes of each component / island

# Are partners of partners also partners?  (triadic closure)
trans_coef(AGR, method = "global")            # global clustering coefficient

# k-core: how deep into the cohesive centre each municipality sits.
table(k_core(AGR))

# Undirected dyad census: how many of the 1,326 pairs are tied vs. not.
dyadic_census(AGR, directed = FALSE)

## ---------------------------------------------------------------------------
## 4. Institutional attributes — do birds of a feather collaborate? (homophily)
## ---------------------------------------------------------------------------
# The paper's thesis: institutional attributes "make the difference". netmem
# reads homophily straight from the matrix + an attribute vector.

# Mixing matrix: ties cross-tabulated by the two partners' PROVINCE.
mix_matrix(AGR, att = prov)

# E-I index in [-1, +1]:  -1 all ties within group (homophily),
#                         +1 all ties across groups (heterophily), 0 = neutral.
ei_index(AGR, mixed = FALSE, att = prov)      # province
ei_index(AGR, mixed = FALSE, att = party)     # mayor's political coalition
ei_index(AGR, mixed = FALSE, att = rural)     # rural vs. urban
# All mildly positive: agreements reach ACROSS provinces, parties and the
# rural/urban divide more than they stay within them — collaboration is not
# simply driven by similarity, leaving room for venue effects (next section).

# How diverse is the region to begin with? Blau's index / IQV for province.
heterogeneity(prov, normalized = TRUE)

## ---------------------------------------------------------------------------
## 5. MULTIPLE POLICY VENUES — the heart of the paper
## ---------------------------------------------------------------------------
# Each venue is a layer over the same 52 municipalities. The EGF question is
# how the layers OVERLAP: do municipalities that co-participate in a mandated
# provincial forum, or a self-organised association, also sign agreements?
#
# jaccard() cross-tabulates two layers dyad-by-dyad and returns:
#   $table       2x2 co-occurrence of ties across the two venues
#   $jaccard     overlap = shared / (shared + either-only)
#   $proportion  share of *agreement* ties also present in the other venue

# Build the MANDATED provincial-forum layer: a tie = sharing a province.
PROVNET <- outer(prov, prov, function(a, b) as.integer(a == b))
diag(PROVNET) <- 0
rownames(PROVNET) <- colnames(PROVNET) <- labs

# Agreements vs. each venue / covariate
jaccard(AGR, PROVNET, directed = FALSE)   # mandated provincial forum  (strongest overlap)
jaccard(AGR, ASSOC,   directed = FALSE)   # self-organised association
jaccard(AGR, NEIGH,   directed = FALSE)   # being geographic neighbours

# Reading the $table for AGR vs PROVNET: of the 119 agreements, the large
# majority join municipalities in the SAME province — the institutional pull of
# the mandated venue, exactly the "expansive" effect the paper finds for
# provincial forums (and which it does NOT find for self-organised venues).

## ---------------------------------------------------------------------------
## 6. Space matters — Moran's I on geographic distance
## ---------------------------------------------------------------------------
# Are well-connected municipalities geographically clustered? spatial_cor()
# weights the attribute (here: agreement degree) by a distance matrix.
spatial_cor(AGR, V = deg, measures = "moran")   # > 0: positive spatial autocorrelation

## ---------------------------------------------------------------------------
## 7. Draw it — venue layers side by side
## ---------------------------------------------------------------------------
plot_layer <- function(M, main, vcol) {
  g <- igraph::graph_from_adjacency_matrix(M, mode = "undirected", diag = FALSE)
  igraph::V(g)$d <- gen_degree(M, digraph = FALSE)
  plot(g, main = main,
       vertex.size = 2 + 1.8 * sqrt(igraph::V(g)$d),
       vertex.color = vcol, vertex.frame.color = "white",
       vertex.label = NA, edge.color = "grey70",
       layout = igraph::layout_with_fr)
}
op <- par(mfrow = c(1, 3), mar = c(0, 0, 2, 0))
plot_layer(AGR,     "Agreements (self-org.)", "#4C72B0")
plot_layer(ASSOC,   "Associations (self-org.)", "#DD8452")
plot_layer(PROVNET, "Provincial forums (mandated)", "#55A868")
par(op)

## ---------------------------------------------------------------------------
## 8. Wrap-up
## ---------------------------------------------------------------------------
# In a few lines of netmem we recovered the descriptive backbone of the paper:
#   * a sparse, single-component agreement network led by the affluent eastern
#     municipalities (degree, components, k-core);
#   * collaboration that is only mildly homophilous on province, party and the
#     rural/urban divide (mix_matrix, ei_index);
#   * agreement ties that overlap most with the MANDATED provincial-forum layer
#     and far less with self-organised associations (jaccard) — the descriptive
#     signature of the "expansive vs. restrictive" venue effects the ERGMs test;
#   * positive spatial clustering of central municipalities (spatial_cor).
#
# From here the paper proceeds to ERGMs (package `ergm`) to test whether these
# overlaps survive once endogenous network dependencies and covariates are held
# constant. The matrices built above (AGR, ASSOC, NEIGH, DIST, PROVNET) and the
# attribute vectors are exactly the inputs such a model needs.
