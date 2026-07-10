Godot 4.7

Still Human (pracovný názov)
Alternatívne názvy na zváženie: SIGNAL LOST / THE ONBOARDING / STATIC ROOM
1. Pitch
Zobudíš sa v jedinej miestnosti: posteľ, klíma, stôl, starý PC žiariaci nápisom WELCOME NEW EMPLOYEE. Za oknom je nepravdepodobne pekná slnečná krajina. Tvoja izba nemá dvere.
Hlas v pevnej linke ti gratuluje k novej práci a vysvetlí pravidlá — s jemným varovaním, že chyby sa "nebudú páčiť". Počas troch zmien spracúvaš cudzie zložky na starom termináli. Nevieš, že každé tvoje rozhodnutie posiela skutočných ľudí do rúk tých, čo ich hľadajú. Jeden z nich si možno ty.
ŽánerPsychologický horor, first-person narrative sim, jedna miestnosťPlatformaPC / Steam, itch.io launchRozsah1 miestnosť, 3 herné zmeny, 2 snové sekvencie, 2 zakončenia, ~45–75 min hrateľnostiInšpirácieSOMA, We Happy Few, Matrix, Blade Runner / Do Androids DreamTím/TimelinePredpoklad: 1–3 ľudia, 6–10 týždňov. Neuviedol/-a si veľkosť tímu — uprav podľa reality, rozsah nižšie je navrhnutý tak, aby to zvládol malý tím.
2. Herný cyklus (Core Loop)
Každý herný deň prebieha v troch fázach:
Fáza A — Telefón (rituál prebudenia)
Hráč sa zobudí na zvonenie. Zdvihnutie telefónu je jediný spôsob, ako postúpiť ďalej — je to aj tvoj hlavný nástroj na podávanie informácií/pravidiel a budovanie atmosféry bez cutscén. Hlas (nazvime ho Handler) vysvetlí:
Deň 1: základné mechaniky, sinister varovanie na záver.
Deň 2: upokojenie ohľadom dymu z ventilácie ("len na zlepšenie produktivity").
Deň 3: varovanie, že ide o najťažšiu zmenu / poďakovanie a "odmena" (podľa cesty).
Prečo telefón a nie NPC alebo text: jeden opakujúci sa hlas, ktorý hráč nikdy nevidí, je lacné na výrobu (žiadna animácia postavy) a psychologicky silnejšie — presne ako v tvojom origináli. Netreba to rozširovať o viac hlasov, aby sa neriedila hrozba.
Fáza B — Terminál (hlavná herná mechanika)
Toto je miesto, kde som najviac dopĺňal — tvoj zápis hovorí len "spravíš svoje úlohy s balíkmi", bez detailu. Navrhujem mechaniku priamo podľa dodaného referenčného dokumentu, len prerámovanú:
Na obrazovke sú dva panely:
Zložka kandidáta (vľavo): meno, sektor pôvodu, dôvod evidencie, skóre. Studené dáta.
Prepis pohovoru (vpravo): krátky dialóg (2–4 riadky) medzi vyšetrovateľom a "kandidátom".
Hráč má tri tlačidlá: CLEAR / HOLD / ESCALATE, plus FLAG — označíš dve časti textu, ktoré si podľa teba protirečia (napr. zložka tvrdí "žiadna rodina", pohovor spomína dieťa). Správne označenie mierne ovplyvní priebeh zmeny (rýchlosť, komentár Handlera); nesprávne ťa spomalí.
Hráč verí, že hodnotí "uchádzačov o zamestnanie" alebo "psychologickú spôsobilosť". V skutočnosti — ako už máš v koncovke A — ide o výsluchy zajatých rebelov a jeho rozhodnutia priamo určujú, kto bude "spracovaný" ďalej. Túto pravdu hráč nevie počas hrania, len sa spätne dozvie v denníku na Deň 3.
Ak si prácu predstavoval/-a inak (fyzické triedenie balíkov, jednoduchšie UI, žiadna "voľba" v úlohe), táto sekcia sa dá vymeniť — zvyšok GDD (dni, konce, miestnosť) na tom nezávisí.
Terminológia: "Balíky" (slovo z tvojho pôvodného zápisu) a "kandidáti/zložky" (moje pomenovanie vyššie) sú to isté— firemný systém len eufemisticky nazýva ľudí "balíkmi", presne tak, ako referenčný dokument nazýva svoje obete "Jednotkami". Nejde o druhý, paralelný herný systém — je to jeden mechanizmus s dvoma menami (jedno neutrálne pre teba ako dizajnéra, jedno dehumanizujúce pre fikciu v hre). V UI aj dialógoch v samotnej hre odporúčam používať výhradne slovo "balík" — posilňuje to tému (firma nevidí ľudí, vidí náklad).
Fáza C — Spánok
Hráč si ľahne. Čo nasleduje, závisí od zvolenej cesty (pozri nižšie).
3. Ústredná záhada — denník a totožnosť
Namiesto samostatnej vedľajšej postavy (ako "Unit 000" v referencii) je tu záhada samotný hráč. Naprieč hrou (najmä v Deň 2–3 snoch) nachádza/počúva fragmenty denníka:
Deň 1: nič — izba pôsobí neutrálne, takmer príjemne.
Deň 2 (sen): šum v telefóne, šepot "Wake up" do ľavého ucha. Prvý náznak, že niekto/niečo sa snaží prebiť cez ilúziu — nie je to Handler.
Deň 3 (len cesta A): plný úryvok denníka — hráč bol rebel bojujúci proti kybernizácii ľudstva, po neúspešnej akcii zajatý, podrobený experimentom. Práca s "kandidátmi" bola v skutočnosti extrakcia informácií o polohe ostatných rebelov z jeho vlastnej pamäte, maskovaná ako administratívna úloha.
Prečo takto: je to lacnejšie ako písať vedľajšiu postavu (žiadny hlas navyše, žiadna nová animácia) a zároveň to dáva twistu maximálnu osobnú váhu — hráč neodhaľuje cudzí príbeh, odhaľuje seba.
Explicitne k Maye/Unit 000: táto hra nemá a nepotrebuje ekvivalent Mayi z referenčného dokumentu. Tam bola Maya nutná preto, lebo Doubt Meter potreboval jeden konkrétny prípad, na ktorom sa kumulatívne rozhodnutia napokon prejavia. Táto hra namiesto metra používa priamu, osobnú vetvu (protagonistova vlastná minulosť), takže ten istý emocionálny účel — "jeden prípad, ktorý sa naprieč hrou prehlbuje" — už plní denník samotného hráča. Pridanie Mayi navyše by vytvorilo presne to riziko, pred ktorým varovala spätná väzba: dve paralelné emocionálne osi namiesto jednej silnej.
4. Naratívny oblúk (3 dni)
Deň 1 — Onboarding
Handler vysvetlí terminál, telefón, základné pravidlo (jednoduché, bez konfliktu — napr. "kandidátov so skóre pod X vždy CLEAR").
Izba je čistá, príjemná, okno ukazuje slnečnú krajinu.
Zmena prebehne bez incidentov. Hráč si ľahne.
Nenápadná predzvesť (voliteľné, lacné): niekde v miestnosti — nálepka/štítok na ventilácii, jeden riadok v pracovnom manuáli na PC, alebo len jemne sladkastý zápach spomenutý v titulku/ambientnom zvuku — naznačí, že vzduch sa "upravuje". Na Deň 1 to hráč prehliadne ako nepodstatný detail; spätne, po Dni 2, to dáva zmysel. Rieši to riziko, že by upchatie vetrania inak pôsobilo ako svojvoľný, nič nenaznačujúci spínač.
Sen: krátka chôdza chodbou → druhý zvoniaci telefón → šum → šepot "Wake up" do ľavého ucha. Prebudenie do Dňa 2.
Deň 2 — Voľba (rozdvojenie)
Z ventilácie sa začne valiť biely dym. Handler telefonicky upokojuje: "len na zlepšenie produktivity, pokračuj ako doteraz." Pravidlo úlohy teraz obsahuje protirečenie (napr. "kandidátov zo Sektora 9 vždy ESCALATE" vs. "kandidátov so súvislou, konkrétnou spomienkou vždy HOLD na ďalšie štúdium") — hráč musí prvýkrát urobiť skutočné rozhodnutie, nie len vyhľadávanie v pravidle.
Hráč má možnosť upchať ventiláciu — toto je hlavná vetviaca voľba hry.
Cesta A — Upchá ventiláciu:
Izba sa okamžite premení: deň sa zmení na noc, zelená krajina za oknom na peklo plné čudnej mašinérie.
Ozve sa hlas podobný Handlerovi: "Robíš chybu."
Zmenu treba dokončiť s glitchujúcim počítačom — na obrazovke sa mihajú slová ako "WAKE UP", "PRISONER".
Na konci dňa žiadne upokojenie od Handlera — ticho, alebo krátky nahnevaný komentár.
Cesta B — Nespraví nič:
Deň prebieha normálne, žiadna zmena prostredia.
Handler na konci: "Ostáva ti posledný deň, choď sa vyspať."
Bez snovej sekvencie — vedomé (alebo nevedomé) odmietnutie pravdy blokuje prístup k spomienkam.
Deň 3 — Zúčtovanie
Ak Cesta A:
Ďalšia snová sekvencia: úryvky denníka odhalia plnú pravdu (pozri sekciu 3).
Po prečítaní sa scéna stmieva, hráč sa budí.
Miestnosť je viditeľne degradovaná — ilúzia sa rozpadá. PC nesvieti. Handler kričí a nadáva namiesto pokojného tónu.
V miestnosti sa objavia dvere. Ich otvorením a prechodom cez ne hra končí.
Ak Cesta B:
Žiadna snová sekvencia, hráč sa budí ako vždy.
Handler varuje, že ide o najťažšiu zmenu zo všetkých — zvláštny dôraz na opatrnosť.
Po dokončení zmeny zavolá znova — tentoraz nadšene a zákerne poďakuje a hráča deaktivuje/"vypne"(predpokladám tento význam slova "odzraví" — uprav, ak si mal/-a na mysli niečo iné, napr. fyzickú likvidáciu alebo doslovné "odzbrojenie"). Odporúčam ponechať slovo "odzraví" priamo vo firemnom dialógu ako zámerný, chladný neologizmus (podobne ako "processing" alebo "decommission" v iných dystópiách) — funguje lepšie než akékoľvek bežné slovo práve preto, že znie byrokraticky a jeho význam nie je hneď stopercentne jasný.
Miestnosť sa pomaly rozplýva do prázdna. Z diaľky zaznievajú výkriky neznámych ľudí a cez ne obrovský smiech — smiech hlasu z telefónu. Koniec.
5. Zakončenia — prehľad
Cesta A — PREBUDENIECesta B — VYMAZANIESpúšťačUpchatie ventilácie v Deň 2Žiadna akcia v Deň 2Deň 3 senÁno — plné odhalenieNieVizuál izbyPostupná degradácia, hellish verziaNezmenená až do koncaTón HandleraNahnevaný, kričíFalošne vrelý → zákernýKoniecDvere sa objavia, hráč odchádza — ambivalentný/nádejnýIzba/hráč mizne do prázdna, smiech — najtemnejší koniecTémaCena spoznania pravdy je neistá, ale je to útečPohodlná poslušnosť vedie k úplnému zániku identity
Prečo len 2 konce, nie 3: tvoj pôvodný dizajn je čisto binárny (upchať/neupchať), a to je v poriadku — netreba umelo pridávať tretí "stredný" koniec len kvôli symetrii s inými hrami. Dve jasne odlíšené, plne napísané cesty je pre malý tím lepšie ako tri polovičné.
6. Miestnosť a interaktivita
Posteľ — spúšťač spánku/prechodu na ďalší deň, v Ceste A aj nositeľ snovej sekvencie.
Stôl + starý PC — terminál, hlavná herná mechanika (sekcia 2B). V Ceste A postupne glitchuje (textové artefakty, farebné aberácie).
Okno — nemenné v Ceste B (stály vizuálny kontrast k realite), v Ceste A sa mení deň→noc a zeleň→peklo. Jeden z najlacnejších, no najsilnejších vizuálnych nástrojov v hre — netreba viac scén, stačí toto jedno okno.
Ventilácia — od Dňa 2 interaktívna (dym, možnosť upchať). Toto je jediný "veľký" rozhodovací bod v hre — nech je vizuálne a zvukovo jasne zvýraznená, hráč nesmie voľbu prehliadnuť.
Telefón — jediný zdroj hlasu/pravidiel/naratívu. Odporúčam nechať zvoniť vždy z rovnakého miesta v miestnosti (žiadna náhodnosť), aby si zvuk zvonenia mohol nabiť silný podmienený reflex strachu do Dňa 3.
Dvere — neexistujú až do konca Cesty A. Ich objavenie sa musí byť najvýraznejší vizuálny moment v hre (svetlo spod dverí, zvuk kľučky) — je to jediná odmena za celú cestu A.
7. Vizuálny a zvukový smer
Základný stav (Deň 1, celá Cesta B): čistý, mierne sterilný, "príliš dokonalý" apartmán. Slnečná krajina za oknom pôsobí takmer ako fototapeta — zámerne mierne "off", aby hráč podvedome tušil, že niečo nesedí, ešte pred akýmkoľvek tvistom.
Degradovaný stav (Cesta A od Dňa 2): nočná/pekelná verzia tej istej miestnosti — rovnaký pôdorys, iné osvetlenie a textúry, aby si ušetril prácu na geometrii a investoval ju do shaderov/osvetlenia.
Terminál: odporúčam dať mu vlastný vizuálny podpis (CRT scanline shader, fyzická otočná páčka na prepínanie medzi zložkou a prepisom) — presne ako v referenčnom dokumente. Jedna výrazná rekvizita > celková atmosféra "ošúchaná izba", ktorá je v hororových indie hrách preplnená.
Zvuk: zvonenie telefónu ako opakujúci sa "leitmotív" strachu; v Ceste A pridať nízkofrekvenčný drone/hum k mašinérii; v koncovke B kontrast medzi falošne vrelým hlasom Handlera a vzdialenými výkrikmi/smiechom na úplný záver.
8. Stav hry a systémy (pre programátora)
Drž stav ako jeden malý objekt, nič viac:
{
  day: 1 | 2 | 3,
  path: null | "A" | "B",   // nastaví sa v Deň 2
  ventBlocked: boolean,
  terminalLog: [ {candidateId, decision, flaggedCorrectly} ]
}
terminalLog nemusí meniť príbeh — stačí ho použiť na drobné flavour-texty (Handler môže na konci zmeny okomentovať presnosť), aby mal terminál pocit dôsledkov bez nutnosti vetviť naratív podľa výkonu. Neodporúčam pridávať ďalšie sledované premenné (napr. "Doubt Meter" ako v referenčnej hre) — tvoj príbeh je binárny, granulárny meter by len pridal prácu bez pridanej hodnoty pre len 2 konce.
9. Produkčné poznámky
Postav najprv Deň 1 kompletne (izba, telefón, terminál, zvuk, svetlo) predtým, než napíšeš čo i len riadok pre Deň 2. Hotový, vyleštený Deň 1 je funkčné demo aj keby si nestihol/-a zvyšok; tri polovičné dni nie sú nič.
Dialógy a texty denníka drž v jednom zdieľanom dokumente (spreadsheet alebo Twine export), nie roztrúsené v scénach — nech ich vie upravovať aj netechnický člen tímu.
Engine: pri jednej miestnosti s dôrazom na svetlo/atmosféru je Unity aj Godot rozumná voľba pre malý tím (ľahšie ako Unreal na rozbeh, dobré nástroje na post-processing pre "hellish" verziu miestnosti). Unreal dáva krajšie svetlo z krabice, ale má vyššiu vstupnú náročnosť — zváž podľa skúseností tímu.
Cesta A si vyžaduje 2 verzie tej istej miestnosti (normálna/degradovaná) — plánuj to od začiatku ako jeden model s prepínateľným materiálovým/osvetľovacím setom, nie ako dve samostatné scény, aby si nezdvojoval prácu.
10. Otvorené otázky (na tvoje potvrdenie/úpravu)
Mechanika úlohy v Terminále — navrhol som "zložka + prepis + flag" systém podľa referenčného dokumentu. Sedí ti to, alebo si predstavoval/-a jednoduchšiu/inú úlohu?
Význam "odzraví" v koncovke B — interpretoval som ako deaktiváciu/vypnutie hráča, a odporúčam ho ponechať ako zámerný neologizmus (pozri sekciu 11.6). Ak si mal/-a na mysli niečo iné (fyzické zabitie, "odzbrojenie" v zmysle straty schopností), uprav sekciu 4.
Rozsah tímu a času — doplň si reálne čísla, aby produkčné poznámky (sekcia 9) sedeli na tvoju situáciu.
11. Dizajnové rozhodnutia — reakcia na spätnú väzbu
Toto je priama odpoveď na štrukturálnu spätnú väzbu k tomuto GDD (Doubt Meter, Maya, terminológia, rozsah). Rozhodnutia nižšie sú záväzné pre zvyšok dokumentu a čiastočne odpovedajú aj na otvorené otázky vyššie.
11.1 Doubt Meter vs. binárna voľba (Deň 2)
Táto hra je postavená na binárnej vetve, nie na kumulatívnom Doubt Metri, a je to zámer, nie prehliadnutie — vyplýva priamo z pôvodného zápisu, kde jediné veľké rozhodnutie je "upchať/neupchať". Zámerne nekopírujeme štruktúru z referenčného dokumentu tam, kde nesedí na tento príbeh.
Aby ale mechanika s balíkmi na termináli (sekcia 2B) nebola čisto kozmetická, terminalLog (sekcia 8) dostáva jednu konkrétnu, lacnú funkciu: na Deň 3 v Ceste A si Handler v hneve môže vziať na mušku konkrétny predchádzajúci "balík", ktorý hráč nesprávne vyhodnotil — napr. spomenie meno človeka, ktorého hráč "vybavil" v Deň 1. Nie je to nová vetva ani nový systém, len jedna referencia v už napísanom texte, ktorá dá hráčovým rozhodnutiam na termináli pocit váhy, aj keď samotný koniec určuje len vent-voľba.
11.2 Maya / Unit 000
Potvrdené: táto hra nepoužíva Mayu ani ekvivalent Unit 000 (podrobné odôvodnenie je doplnené priamo v sekcii 3). Nejde o zošitie dvoch hier dokopy — je to vedomé nahradenie jednej emocionálnej osi (cudzí prípad) inou (vlastná identita hráča), ktorá je pre tento príbeh silnejšia aj lacnejšia na výrobu. Ak by sa Maya niekedy mala pridať späť, musela by nahradiť denníkovú líniu, nie bežať popri nej — dve paralelné odhalenia by si v 45–75 minútach hry navzájom konkurovali o pozornosť hráča.
11.3 "Balíky" = "kandidáti/zložky" (zjednotená terminológia)
Vyriešené priamo v sekcii 2B — ide o jeden systém, dve mená (dizajnérske pomenovanie vs. vnútroherný firemný eufemizmus). V samotnej hre sa vždy hovorí len o "balíkoch".
11.4 Rozsahová bilancia — čo je "zadarmo" a čo je nová práca (Cesta A)
Prvok Cesty ANáročnosťPoznámkaZmena osvetlenia izby (deň→noc)ZadarmoLen iný lighting/skybox setup na tej istej scéneZmena obrazu za oknom (zeleň→peklo)Takmer zadarmoVýmena textúry/matte-paintingu za oknom, žiadna nová geometriaZvuk (drone, hum, nahnevaný Handler)LacnéAudio úpravy + jedna extra VO nahrávka pre nahnevaný tónGlitch-text overlay na PCLacné–strednéJeden shader/UI efekt, znovupoužiteľný kdekoľvek na obrazovke termináluAnimovaná mašinéria v pozadíNová prácaAk má ísť o viac než statickú textúru/siluetu, treba nové modely + animácie — najdrahšia položka v Ceste AMizajúca miestnosť (koniec B)Nová prácaVFX rozkladu/rozpúšťania geometrie, vyžaduje čas na doladenie tempaExtra VO pre krik/smiech (koniec B)LacnéKrátke, dá sa nahrať v tej istej session ako Handler
Odporúčanie: ak dôjde čas, prvá vec na obetovanie je animovaná mašinéria — nahraď ju statickými siluetami/matte-paintingom s jemným pohybom svetla (rovnaký trik ako pri okne). Rozklad miestnosti v koncovke B si ale ponechaj — je to najsilnejší obraz v celej hre a stojí za investíciu.
11.5 Predzvesť pre vent-twist
Doplnené priamo do Dňa 1 (sekcia 4, bod "Nenápadná predzvesť") — rieši pripomienku, že upchatie vetrania by inak mohlo pôsobiť ako svojvoľný spínač bez nadväznosti.
11.6 "Odzraví"
Ponechať ako zámerný firemný neologizmus — pozri doplnenú poznámku v Deň 3 / Cesta B (sekcia 4). Netreba nahrádzať bežným slovom.
11.7 Ambiguita konca A
Bez zmeny — spätná väzba potvrdzuje, že nevysvetlená dvojznačnosť (sloboda, alebo smrť?) sedí na tón hry presne tak, ako je navrhnutá v sekcii 5.
