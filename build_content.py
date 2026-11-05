"""Builds assets/data/*.json from parsed Act sections. Run:
python3 tools/parse_act.py <Act.pdf> /tmp/act_sections.json
python3 tools/build_content.py /tmp/act_sections.json <starter legal_content.json> assets/data docs
"""
import json, re, sys
raw=json.load(open(sys.argv[1])); starter=json.load(open(sys.argv[2])); OUT=sys.argv[3]; DOCS=sys.argv[4]

def base(n): return int(re.match(r'\d+',n).group())
def clean(t):
    t=re.split(r'\n1 Throughout this Act',t)[0]
    t=re.sub(r'(?<![\w.,])\d{1,3}\[','[',t)           # strip footnote numbers glued to "["
    t=re.sub(r'\n(?=\(|Explanation|Illustration|Provided|Exception|Note)', '\n\n', t)
    t=re.sub(r'(?<!\n)\n(?!\n)',' ',t)
    return re.sub(r'[ \t]+',' ',t).strip()

# ---- thematic mapping: primary chapter per section (reviewable!) ----
def primary(n):
    b=base(n); s=n
    if b==3 or 5<=b<=16: return 1
    if 17<=b<=31: return 2
    if b in (32,33): return 3
    if b==4 or 79<=b<=90 or b in (112,114): return 4
    if 45<=b<=51: return 5
    if 56<=b<=78 or 91<=b<=100: return 6
    if b==113 or 101<=b<=111: return 7
    if 115<=b<=117: return 8
    if 121<=b<=129: return 10
    if 118<=b<=120 or 130<=b<=166: return 9
    return 11   # 1,2,34-44,52-55,167
RELATED={'3':[4],'4':[7],'112':[7],'114':[7],'34':[6],'35':[6],'36':[6],'37':[6],'38':[6],'39':[6],
 '45':[6],'45A':[6],'47A':[6],'65A':[4],'65B':[4],'123':[9],'124':[9],'32':[2]}
FLAGS={
 '2':['Repealed section (Repealing Act 1938) - kept for completeness; no quiz content.'],
 '32':['Chapter 3 teaches s.32(1) (dying declaration). Other clauses (2)-(8) are in the same statutory text and are NOT yet taught separately.'],
 '114':['Primary chapter: Presumptions. Also referenced from Burden of Proof.'],
 '112':['Not in your original mapping. Placed in Presumptions (conclusive proof of legitimacy); cross-referenced to Burden of Proof. Please review.'],
 '113':['Not in your original mapping. Placed with Burden of Proof (statutory Chapter VII). Please review.'],
}
ADDED_NOTE={'33':'Not in your original mapping; grouped with s.32 (statements of persons who cannot be called). Review.',
 '34':'Unassigned in original mapping; placed in Miscellaneous (relevancy of entries/statements in records) with cross-ref to Proof. Review.'}
sections=[]; byn={}
for i,r in enumerate(raw):
    n=r['number']; b=base(n); pc=primary(n)
    st=next((x for x in starter['sections'] if x['number']==n),None)
    flags=list(FLAGS.get(n,[]))
    if n in ADDED_NOTE: flags.append(ADDED_NOTE[n])
    if (36<=b<=44) or 52<=b<=55 or b in (1,): flags.append('Placed in Miscellaneous because it was unassigned in the original mapping. Review.')
    if 74<=b<=78 or 91<=b<=100: flags.append('Not in original mapping range (56-73); placed in Proof. Review.')
    flags.append('Title not verified: official marginal heading not reliably extracted from PDF layout.' if not st else 'Title and explanations are starter drafts (educational, not official).')
    s={'sectionId':'s'+n.lower(),'sectionNumber':n,'primaryChapterId':f'ch{pc:02d}',
       'relatedChapterIds':[f'ch{c:02d}' for c in RELATED.get(n,[])],
       'statutoryPart':r['part'],'statutoryChapter':r['chapter'],'statutoryChapterTitle':r['chapterTitle'],
       'sectionTitle':st['title'] if st else None,
       'originalText':(lambda t: t[:t.index('varied the decision.')+20] if n=='167' else t)(clean(r['text'])),
       'banglaTranslation':None,
       'englishExplanation':st['english'] if st else None,
       'banglaExplanation':st['bangla'] if st else None,
       'practicalExample':None,
       'displayOrder':i,
       'sourceReference':f"Evidence Act 1872, bdlaws.minlaw.gov.bd print copy, PDF p.{r['page']}"+(' (inserted/amended by Evidence (Amendment) Act 2022; bracketed in source)' if n[-1].isalpha() else ''),
       'contentStatus':'starter_draft' if st else 'original_text_only',
       'marginNoteRaw':r['marginNote'],'reviewFlags':flags}
    sections.append(s)

CH=[('Fact','তথ্য / ঘটনা','scales','What counts as a fact, facts in issue, and when other facts become relevant (ss. 3, 5-16).'),
('Admission and Confession','স্বীকৃতি ও স্বীকারোক্তি','chat','Admissions (ss.17-23, 22A) and confessions (ss.24-30); s.31.'),
('Dying Declaration','মৃত্যুকালীন ঘোষণা','scroll','Statements about the cause of death - s.32(1) - and related statements of persons who cannot be called (s.33).'),
('Presumptions','অনুমান','balance','"May presume", "shall presume", conclusive proof; presumptions as to documents and digital records; ss.112, 114.'),
('Opinion of Third Parties','তৃতীয় পক্ষের মতামত','people','Expert opinion and other opinions (ss.45-51, incl. 45A, 47A).'),
('Proof','প্রমাণ','books','Facts needing no proof, oral and documentary evidence, public documents, digital records, exclusion of oral by documentary evidence.'),
('Burden of Proof','প্রমাণের ভার','gavel','Who must prove what (ss.101-111, 113).'),
('Estoppel','এস্টপেল','handshake','Estoppel by declaration, act or omission (ss.115-117).'),
('Examination of Witness','সাক্ষীর পরীক্ষা','witness','Competence of witnesses, examination, cross-examination, questions, impeachment (ss.118-120, 130-166).'),
('Privileged Communication','বিশেষাধিকারপ্রাপ্ত যোগাযোগ','shield','Communications a witness cannot be compelled to disclose (ss.121-129).'),
('Miscellaneous','বিবিধ','scales2','Preliminary provisions, relevancy of entries/judgments, character evidence, and s.167.')]
BONUS=[50,60,50,60,60,70,70,50,70,60,50]
chapters=[]
for i,(en,bn,ic,d) in enumerate(CH,1):
    cid=f'ch{i:02d}'
    chapters.append({'chapterId':cid,'chapterNumber':i,'chapterName':en,'chapterNameBangla':bn,'description':d,'icon':ic,
      'displayOrder':i,'bonusXP':BONUS[i-1],'prerequisiteChapterId':None if i==1 else f'ch{i-1:02d}',
      'sectionIds':[s['sectionId'] for s in sections if s['primaryChapterId']==cid],
      'relatedSectionIds':[s['sectionId'] for s in sections if cid in s['relatedChapterIds']]})
assert sum(len(c['sectionIds']) for c in chapters)==len(sections)

# ---- questions ----
Q=[]
def q(sec,en,opts,ans,expl,diff='easy',xp=5,bossOnly=False):
    sid='s'+sec.lower(); ch=next(s['primaryChapterId'] for s in sections if s['sectionId']==sid)
    Q.append({'questionId':f'q{len(Q)+1:03d}','sectionId':sid,'chapterId':ch,'questionTextEnglish':en,'questionTextBangla':None,
      'optionsEnglish':opts,'optionsBangla':None,'correctAnswer':ans,'explanationEnglish':expl,'explanationBangla':None,
      'difficulty':diff,'xpReward':xp,'source':'starter'})
for st in starter['questions']:
    m=re.search(r'section (\d+[A-Z]?)',st['question']) or re.search(r'section (\d+[A-Z]?)',st['explanation'])
    sec={'Which principle is expressed in section 6?':'6','What does section 60 require for oral evidence?':'60'}.get(st['question'], m.group(1) if m else '5')
    if 'section 65B' in st['question']: sec='65A'
    if 'section 101' in st['question']: sec='101'
    q(sec,st['question'],st['options'],st['answer'],st['explanation'])
q('25','Under section 25, may a confession made to a police-officer be proved against the person accused of an offence?',
  ['Yes, if it was voluntary','No - it shall not be proved as against the accused','Only if the accused signed it','Only in civil cases'],1,
  'Section 25: no confession made to a police-officer shall be proved as against a person accused of any offence.')
q('26','Under section 26, a confession made while the accused is in police custody can be proved only if made in the immediate presence of whom?',
  ['A senior police officer','A village headman','A Magistrate','Any two witnesses'],2,
  'Section 26 excludes confessions made in police custody unless made in the immediate presence of a Magistrate (the Explanation limits who counts as a Magistrate).','medium')
q('24','Under section 24, a confession in a criminal proceeding is irrelevant if caused by an inducement, threat or promise proceeding from whom?',
  ['A co-accused','A person in authority','Any private person','The accused himself'],1,
  'Section 24 requires the inducement, threat or promise to have reference to the charge and to proceed from a person in authority.','medium')
q('32','Section 32(1) makes relevant a statement by a person about which matter?',
  ['His property','The cause of his death or circumstances of the transaction that resulted in his death','His age','His reputation'],1,
  'Section 32(1) covers statements as to the cause of death, or any circumstances of the transaction which resulted in death, where the cause of death comes into question.')
q('32','Under section 32(1), must the maker have been under expectation of death when the statement was made?',
  ['Yes, always','No - such statements are relevant whether or not he was under expectation of death','Only in civil proceedings','Only if made to a Magistrate'],1,
  'The text of s.32(1) says such statements are relevant whether or not the person was under expectation of death, whatever the nature of the proceeding.','medium')
q('102','Under section 102, on whom does the burden of proof in a suit or proceeding lie?',
  ['The person who would fail if no evidence at all were given on either side','Always the defendant','Always the plaintiff','The Court'],0,
  'Section 102 places the burden on the person who would fail if no evidence were given on either side.')
q('106','Under section 106, who must prove a fact that is especially within the knowledge of a person?',
  ['The opposite party','That person himself','The Court','The prosecution always'],1,
  'Section 106: when any fact is especially within the knowledge of any person, the burden of proving that fact is upon him.')
q('115','What does section 115 prevent a person from doing?',
  ['Denying the truth of a thing he intentionally caused another to believe and act upon','Calling any witness','Proving a document','Cross-examining'],0,
  'Estoppel (s.115): a person who by declaration, act or omission intentionally caused another to believe a thing and act on it cannot deny its truth in a suit or proceeding between them or their representatives.')
q('118','Under section 118, who is competent to testify?',
  ['Only adults','All persons, unless prevented from understanding questions or giving rational answers (by tender years, extreme old age, disease or similar cause)','Only literate persons','Only persons who take an oath in Court'],1,
  'Section 118 makes all persons competent unless the Court considers they are so prevented; a lunatic is not incompetent unless prevented by lunacy (Explanation).','medium')
q('122','Section 122 protects which kind of communication?',
  ['Communications between spouses made during marriage','Communications between neighbours','Communications to a police officer','Communications in open Court'],0,
  'Section 122: a person who is or has been married cannot be compelled (or, without consent, permitted) to disclose a communication made during marriage, subject to the exceptions in the section.','medium')
q('126','Under section 126, an Advocate may disclose client communications made in the course of employment only with what?',
  ['The Court\'s silence','His client\'s express consent (subject to the Provisos)','A police request','Never in any case'],1,
  'Section 126 bars disclosure unless with the client\'s express consent, subject to the provisos in the section.','medium')
q('4','What does "conclusive proof" mean under section 4?',
  ['The Court may call for more proof','On proof of one fact, the Court shall regard the other as proved and not allow evidence to disprove it','The fact is presumed until disproved','The fact is irrelevant'],1,
  'Section 4: when one fact is declared conclusive proof of another, the Court shall on proof of the one regard the other as proved and shall not allow evidence to disprove it.','medium')
q('45','Under section 45 (as amended in 2022), whose opinions are relevant on points such as foreign law, science, physical or forensic evidence or digital record, art, handwriting or finger impression?',
  ['Any witness','Persons specially skilled in the matter (experts)','Only the Judge','Only the parties'],1,
  'Section 45: the opinions of persons specially skilled in the relevant field are relevant facts; such persons are called experts.')

games=[
 {'gameId':'g001','chapterId':'ch02','sectionId':'s25','gameType':'true_false','title':'Confessions: true or false?','instructions':'Decide whether each statement matches the Act.','xpReward':15,
  'content':{'items':[
   {'statement':'No confession made to a police-officer shall be proved as against a person accused of any offence (s.25).','answer':True,'explanation':'This is the text of s.25.'},
   {'statement':'A confession in police custody is always admissible if the accused signs it.','answer':False,'explanation':'s.26 requires the immediate presence of a Magistrate.'},
   {'statement':'An inducement, threat or promise must have reference to the charge for s.24 to apply.','answer':True,'explanation':'s.24 requires reference to the charge against the accused.'}]}},
 {'gameId':'g002','chapterId':'ch07','sectionId':'s101','gameType':'true_false','title':'Burden of proof: true or false?','instructions':'Decide whether each statement matches the Act.','xpReward':15,
  'content':{'items':[
   {'statement':'The burden lies on the person who would fail if no evidence were given on either side (s.102).','answer':True,'explanation':'This is s.102.'},
   {'statement':'A fact especially within a person\'s knowledge must always be proved by the other side.','answer':False,'explanation':'s.106 puts that burden on the person with the knowledge.'}]}},
 {'gameId':'g003','chapterId':'ch02','sectionId':'s25','gameType':'match','title':'Match the legal term','instructions':'Match each provision to its effect.','xpReward':15,
  'content':{'pairs':[{'left':'s.25','right':'Confession to a police-officer cannot be proved against the accused'},
   {'left':'s.32(1)','right':'Statement as to cause of death can be relevant'},
   {'left':'s.106','right':'Burden on the person with special knowledge'},
   {'left':'s.115','right':'Estoppel by declaration, act or omission'}]}},
 {'gameId':'g004','chapterId':'ch02','sectionId':'s25','gameType':'fill_blank','title':'Fill in the missing word','instructions':'Pick the word that completes the text of the Act.','xpReward':15,
  'content':{'items':[{'prompt':'No confession made to a police-officer shall be ____ as against a person accused of any offence.','options':['proved','admired','denied','forgotten'],'answer':0,'ref':'s.25'},
   {'prompt':'When any fact is especially within the ____ of any person, the burden of proving that fact is upon him.','options':['custody','knowledge','possession','memory'],'answer':1,'ref':'s.106'}]}},
 {'gameId':'g005','chapterId':'ch08','sectionId':'s115','gameType':'identify_section','title':'Identify the relevant section','instructions':'Read the situation and choose the section.','xpReward':15,
  'content':{'items':[{'scenario':'A tells the police, in custody, that he committed the theft. Which section bars proving this against A?','options':['s.25','s.106','s.115','s.122'],'answer':0,'explanation':'s.25 - confession to a police-officer.'},
   {'scenario':'A falsely and intentionally leads B to believe land is A\'s, and B buys it. Which doctrine stops A denying that later?','options':['s.25','s.32','s.115','s.126'],'answer':2,'explanation':'s.115 - estoppel (the section\'s own illustration).'}]}},
 {'gameId':'g006','chapterId':'ch07','sectionId':'s106','gameType':'case','title':'Case scenario challenge','instructions':'Read the case and answer.','xpReward':20,
  'content':{'items':[{'scenario':'A is charged with travelling on a railway without a ticket. Whether he had a ticket is a fact especially within his knowledge.','question':'On whom does the burden of proving he had a ticket lie?','options':['The railway','A himself','The Court','A witness'],'answer':1,'explanation':'s.106 illustration (b): the burden is on him.'}]}},
]
def bq(sec,en,opts,ans,expl):
    return {'sectionRef':sec,'question':en,'options':opts,'answer':ans,'explanation':expl}
bosses={
 'ch02':{'chapterId':'ch02','title':'Boss battle: The Police Station Confession','scenario':'X is accused of robbery. While in police custody, X tells the investigating officer, with no Magistrate present, that he took the money. At trial the prosecution wants to prove this.','passPercent':60,'xpReward':40,
  'questions':[bq('s25','Which section most directly bars proving this statement against X?',['s.25','s.115','s.126','s.4'],0,'s.25: no confession made to a police-officer shall be proved against a person accused of any offence.'),
   bq('s26','If X had made it in police custody, what does s.26 additionally require for it to be proved?',['Presence of a Magistrate','Presence of an advocate','Presence of two villagers','Nothing'],0,'s.26: unless made in the immediate presence of a Magistrate.'),
   bq('s24','If an officer of authority had promised X leniency in reference to the charge, which section would make the confession irrelevant in a criminal proceeding?',['s.24','s.32','s.102','s.118'],0,'s.24 covers inducement, threat or promise from a person in authority.')]},
 'ch03':{'chapterId':'ch03','title':'Boss battle: The Last Words','scenario':'V is fatally injured and, before dying, tells a neighbour who attacked him and how. V did not say he expected to die. The cause of V\'s death is in question at the trial.','passPercent':60,'xpReward':40,
  'questions':[bq('s32','Which provision may make V\'s statement relevant?',['s.32(1)','s.25','s.106','s.122'],0,'s.32(1): statement as to the cause of death or circumstances of the transaction that resulted in death.'),
   bq('s32','Does the absence of any expectation of death make the statement irrelevant?',['Yes','No - relevant whether or not under expectation of death','Only in civil cases','Only if a Magistrate recorded it'],1,'The text of s.32(1) says so expressly.')]},
 'ch07':{'chapterId':'ch07','title':'Boss battle: The Ticketless Traveller','scenario':'A sues B for land B possesses, claiming it passed to A under a will. Separately, C is charged with travelling by rail without a ticket.','passPercent':60,'xpReward':40,
  'questions':[bq('s102','In A\'s suit, on whom is the burden (if no evidence were given by either side B keeps possession)?',['A','B','The Court','C'],0,'s.102 illustration (a): B would retain possession, so the burden is on A.'),
   bq('s106','Who must prove C had a ticket?',['The railway','C','The Court','The Magistrate'],1,'s.106 illustration (b).')]},
 'ch08':{'chapterId':'ch08','title':'Boss battle: The Land Sale','scenario':'A intentionally and falsely leads B to believe certain land is A\'s, and B buys and pays for it. The land later becomes A\'s property and A sues B to recover it.','passPercent':60,'xpReward':40,
  'questions':[bq('s115','Which principle prevents A from denying that the land was his to sell?',['Estoppel (s.115)','Burden (s.102)','Privilege (s.126)','Competence (s.118)'],0,'s.115 and its illustration.')]},
}
json.dump(sections,open(f'{OUT}/sections.json','w'),ensure_ascii=False,indent=1)
json.dump(chapters,open(f'{OUT}/chapters.json','w'),ensure_ascii=False,indent=1)
json.dump(Q,open(f'{OUT}/questions.json','w'),ensure_ascii=False,indent=1)
json.dump(games,open(f'{OUT}/games.json','w'),ensure_ascii=False,indent=1)
json.dump(bosses,open(f'{OUT}/bosses.json','w'),ensure_ascii=False,indent=1)
# coverage report
L=['# Coverage report (auto-generated)','',f'Total section records: {len(sections)} (167 base + 15 inserted by Evidence (Amendment) Act 2022)','']
L.append('| # | Chapter | Sections | Qs |'); L.append('|---|---|---|---|')
for c in chapters:
    nums=[s['sectionNumber'] for s in sections if s['sectionId'] in c['sectionIds']]
    L.append(f"| {c['chapterNumber']} | {c['chapterName']} | {len(nums)}: {', '.join(nums[:6])}{'...' if len(nums)>6 else ''} | {sum(1 for x in Q if x['chapterId']==c['chapterId'])} |")
L+=['','## Placement differences from your prompt (please review)','- Added to chapters not in your list: 1-2, 34-44, 52-55 -> Miscellaneous; 33 -> Dying Declaration; 74-78, 91-100 -> Proof; 112 -> Presumptions; 113 -> Burden of Proof; 130-166 -> Examination of Witness.','- 121-129 are in Privileged Communication only (removed from Examination of Witness) to avoid duplicate records.','- 114 is primary in Presumptions, cross-referenced from Burden of Proof (not duplicated).','- 32 is one record; only clause (1) is taught in chapter 3.','','## Sections with starter explanations only: '+', '.join(s['sectionNumber'] for s in sections if s['contentStatus']=='starter_draft'),'','## Sections with no questions yet: '+str(sum(1 for s in sections if not any(x['sectionId']==s['sectionId'] for x in Q)))+' of '+str(len(sections))]
open(f'{DOCS}/COVERAGE_REPORT.md','w').write('\n'.join(L))
print('\n'.join(L[:22]))
