# Wishlist - Mily Jezisku

_Mozna neco ani nejde, mozna neco chapu spatne, ale moc rad se na to budu podilet, pomuzu, vyzkousim a dozvim se vice._


## API Docker

Prosim, zda by slo, abych nemusel delat migraci apod.

Proste si stahnu a zacnu pouzivat konkretni verzi API docker-compose (tedy db a serveru a dalsich).
Mohu stahnout ostrou, mohu stahnout develop, mohu stahnout konkretni branch.

Konfigurace neonu mohu mit ve svem adresari, kde to budou poustet (a asi se namapuje jako treba ./config?),
jinak nic jineho - vse bude v dockeru.

**In works**
Mám připravenej script, kterej nasetupuje branch. Akorát je ještě rozbitej (zasekává se). Docker-compose je verzovanej, takže to je ok, akorát se musím dostat přes ten apache.


## React Docker

Moc rad bych mel moznost featuru proste dat k testovani jako moji branch proti konkretnimu api.
Fakticky to asi je jen nejaky node nebo nginx, protoze vetsina reacu bude statickeho a bude komunikovat jen pres api.

Moc rad bych, aby kazdy featura, ale i development branch mela moznost byt testovana v ramci nejakeho CI.
Tedy kdyz to pushnu, tak se spusti testovani a je videt, ze to bezi nejen u me, ale i na ciste a spravne nakonfugovanem stroji
(protoze lokalne mame ruzne package globalne a podobne).

Je pak take jednodussi proti tomu poustet akceptacni testy (ala uzivatel, co klika v browseru).

**Teamcity**
Když zdokumentujete, jak vaše testy pustim, můžu je přidat do našeho CI :P



_no a vice samozrejme, ale to postupne_