import treeswift, sys

T = treeswift.read_tree_newick(sys.argv[1])
T.resolve_polytomies()
print(T)


