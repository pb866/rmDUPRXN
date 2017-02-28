def retrSTRNG(duprxn):
    import numpy as np

    for l in range(len(duprxn)):
        spl = duprxn[l].split(':')
        fkpp = '.'+spl[1]
        dl = int(spl[2])
        RIND = spl[4]
        rxn = np.empty(2,int)
        i1 = RIND.index('<')+1
        i2 = RIND.index('>')
        rxn[0] = RIND[i1:i2]
        i1 = RIND.index('<',RIND.index('='))+1
        i2 = RIND.index('>',RIND.index('='))
        rxn[1] = RIND[i1:i2]

        replSTRNG(dl-1, dl+rxn[0]-rxn[1], fkpp)

def replSTRNG(dl,rl,fkpp):

    print dl,rl,fkpp
    with open(fkpp,'rw') as f:
        ll = f.readlines()
        drxn = react(ll[dl])

        for l in reversed(xrange(rl)):
            rrxn = react(ll[l])
            if drxn == rrxn:
                break

        print l, rrxn

def react(line):

    edct = line[line.index('}')+1:line.index('=')].strip()
    prod = line[line.index('=')+1:line.index(':')].split('+')
    prod = sorted([p.strip() for p in prod])

    return edct,prod

