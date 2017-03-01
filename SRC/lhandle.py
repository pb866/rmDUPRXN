def retrSTRNG(duprxn):
    import numpy as np

    dupind = []
    rlkpp  = []
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

        dr, ldup = fndSTRNG(dl-1, dl+rxn[0]-rxn[1], fkpp)
        ldup = replSTRNG(ldup, dl, dr)
        dupind.append([dr, dl-1])
        rlkpp.append(ldup[dr])

    return dupind, rlkpp


def fndSTRNG(dl, rl, fkpp):

    with open(fkpp,'rw') as f:
        ll = f.readlines()
        drxn = react(ll[dl])

        for l in reversed(xrange(rl)):
            rrxn = react(ll[l])
            if drxn == rrxn:
                break

    return l,ll

def react(line):

    edct = line[line.index('}')+1:line.index('=')].strip()
    prod = line[line.index('=')+1:line.index(':')].split('+')
    prod = sorted([p.strip() for p in prod])

    return edct,prod


def replSTRNG(ldup, dl, dr):

    rate1 = ldup[dr][ldup[dr].index(':')+1:ldup[dr].index(';')].strip()
    rate2 = ldup[dl][ldup[dl].index(':')+1:ldup[dl].index(';')].strip()

    ldup[dr] = ldup[dr][:ldup[dr].index(':')+1]+"  "+rate1+"+"+rate2+" ;\n"
    ldup[dl] = ""
    return ldup

def wrtKPP(di,ldup):

    print 'wrtKPP:\n'
    print len(ldup),len(di)
#   sorted(di,key=lambda di: di[1], reverse=True)
    print di
    with open('../mechanisms/halfMCM1tchr.kpp','rw+') as f:
        line = f.readlines()
        for i in range(len(ldup)):
            line[di[i][0]] = ldup[i]
            line[di[i][1]] = ""

    with open('../test.kpp','w+') as f:
        for i in range(len(line)):
            f.write(line[i])

