"""Parse bdlaws Evidence Act PDF into section records (statutory text only).
Column-aware: body column x0>=145pt, margin notes x0<145pt."""
import pdfplumber, re, json, sys
SRC=sys.argv[1]; OUT=sys.argv[2]
NUM=re.compile(r'^(?:\d{1,3}\[|\[)?(\d{1,3})([A-Z]{0,2})\.$')
def key(n,s): return (n,s)
pdf=pdfplumber.open(SRC)
lines=[]  # (page, margin, body)
for pi,pg in enumerate(pdf.pages):
    rows={}
    for w in pg.extract_words(keep_blank_chars=False):
        rows.setdefault(round(w['top']/4),[]).append(w)
    for k in sorted(rows):
        ws=sorted(rows[k],key=lambda w:w['x0'])
        txt=' '.join(w['text'] for w in ws)
        if 'bdlaws.minlaw.gov.bd' in txt or txt.startswith('04/11/2026'): continue
        m=[w for w in ws if w['x0']<145]; b=[w for w in ws if w['x0']>=145]
        lines.append((pi+1,' '.join(w['text'] for w in m),b))
sections=[];cur=None;part=chap=chaptitle='';last=(0,'')
pending_chapter=None
for pg,margin,b in lines:
    btxt=' '.join(w['text'] for w in b)
    mm=re.fullmatch(r'(PART)\s+([IVX]+)',btxt)
    if mm: part='Part '+mm.group(2); pending_chapter=None; continue
    mm=re.fullmatch(r'CHAPTER\s+([IVXL]+)',btxt)
    if mm:
        chap='Chapter '+mm.group(1); pending_chapter=True; continue
    if pending_chapter and btxt.isupper() and len(btxt)>3:
        chaptitle=btxt.title(); pending_chapter=None; continue
    pending_chapter=None
    start=None
    if b:
        cand=[]
        if len(b)>1: cand.append(b[0])
        if len(b)>2 and re.fullmatch(r'\d{1,3}',b[0]['text']) and b[1]['x0']<200: cand.append(b[1])  # footnote no. before "[65A."
        for w in cand:
            mt=NUM.match(w['text'])
            if mt and 145<=b[0]['x0']<=175:
                k=(int(mt.group(1)),mt.group(2))
                if k>last and (k[0]-last[0])<=12:
                    start=k
                break
    if start:
        last=start
        cur={'number':f'{start[0]}{start[1]}','part':part,'chapter':chap,'chapterTitle':chaptitle,
             'page':pg,'marginNote':margin,'lines':[btxt]}
        sections.append(cur)
    elif cur is not None:
        if margin and len(cur['lines'])<=4: cur['marginNote']=(cur['marginNote']+' '+margin).strip()
        if btxt: cur['lines'].append(btxt)
for s in sections:
    s['marginNote']=s['marginNote'][:160]
    s['text']='\n'.join(s.pop('lines'))
json.dump(sections,open(OUT,'w'),ensure_ascii=False,indent=1)
print(len(sections),'sections;',sections[0]['number'],'->',sections[-1]['number'])
