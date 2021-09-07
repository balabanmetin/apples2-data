#! /usr/bin/env python
import sys

def readfq(fp): # this is a generator function
    last = None # this is a buffer keeping the last unprocessed line
    while True: # mimic closure; is it a bad idea?
        if not last: # the first record or a record following a fastq
            for l in fp: # search for the start of the next record
                if l[0] in '>@': # fasta/q header line
                    last = l[:-1] # save this line
                    break
        if not last: break
        name, seqs, last = last[1:].partition(" ")[0], [], None
        for l in fp: # read the sequence
            if l[0] in '@+>':
                last = l[:-1]
                break
            seqs.append(l[:-1])
        if not last or last[0] != '+': # this is a fasta record
            yield name, ''.join(seqs), None # yield a fasta record
            if not last: break
        else: # this is a fastq record
            seq, leng, seqs = ''.join(seqs), 0, []
            for l in fp: # read the quality
                seqs.append(l[:-1])
                leng += len(l) - 1
                if leng >= len(seq): # have read enough quality
                    last = None
                    yield name, seq, ''.join(seqs); # yield a fastq record
                    break
            if last: # reach EOF before reading enough quality
                yield name, seq, None # yield a fasta record instead
                break

if __name__ == "__main__":
    n, slen, qlen = 0, 0, 0
    dct={}
    f=open(sys.argv[1])
    for name, seq, qual in readfq(f):
        if seq in dct:
            dct[seq].append(name)
        else:
            dct[seq]=[name]
    
    f.close()
    res=[]
    duplist=[]
    for k,v in dct.items():
        res.append(">"+v[0])
        res.append(k)
        if len(v) > 1:
            duplist.append("\t".join(v))
    with open(sys.argv[2],"w") as of:
        of.write("\n".join(res))
        of.write("\n")
    with open(sys.argv[3],"w") as df:
        df.write("\n".join(duplist))
        df.write("\n")

