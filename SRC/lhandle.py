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

        replSTRNG(dl, dl+rxn[0]-rxn[1], fkpp)

def replSTRNG(dl,rl,fkpp):

    print dl,rl,fkpp
    with open(fkpp,'rw') as f:
        ll = f.readlines()
        print ll[dl-1]
        print ll[rl-4]
