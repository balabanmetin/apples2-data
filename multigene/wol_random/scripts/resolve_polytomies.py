import dendropy,sys

T = dendropy.Tree.get(path=sys.argv[1], schema='newick')
T.resolve_polytomies()
print(T.as_string(schema='newick'))


