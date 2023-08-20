# Wprowadzenie
Aplikacja skupia sie wokol automatyzacji odswiezania modelu tabelarycznego. W oparciu o dwa pliki konfiguracyjne, wypelniane przez uzytkownika, wykonane zostaje procesowanie danych na tabularze. Wynik odswiezania zostaje umieszczony na wskazanym blobie w notacji JSON.

## Wykorzystywane technologie
Aplikacja napisana zostala w calosci w jezyku powershell, wykorzystujac ponizsze moduly:
```
- powershell-yaml 
- SqlServer
- Az.Accounts
- Az.Storage
```

Aplikacja, w toku jej dzialania odwoluje sie rowniez do wskazanych obiektow:
```
- Model Tabelaryczny w usludze Azure Analysis Services
- Azure Storage Account
```

## Zalecana wersja programu powershell
Calosc zostala napisana i przetestowana w Powershell 7 (Core). Dla zapewnienia poprawnosci dzialania skrpytow, zalecane jest uzywanie tej samej wersji powershella.

# Instalacja
```
git clone https://github.com/PadreMateo8/refresh_tabular.git
```

## Wypelnienie pliku .yml
```
Serwer: asazure://westeurope.asazure.windows.net/aastabular
Model: Tabular - PROD
Tabele:
- _master_content
- _master_coverages
- _master_domains_monthly
- _master_keywords
- _master_keywords_pages
- _master_pages
Godziny:
- 8
- 16
Aktywny: TAK
```

W oparciu o powyzsze, aplikacja odswiezy szesc tabel pochodzacych z modelu 'Loreal - PROD' o dwoch godzinach (8-ej i 16-tej). Parametr 'Aktywny' moze zostac zmieniony na 'NIE' w przypadku, gdy chcemy zatrzymac calkowicie uruchomienie skryptu.

## Wypelnienie pliku .config
```
UID:testowy.mail@email.pl
PWD:pwd1234
TENANT_ID:1293045190-qce123
SUBSCRIPTION_ID:40b51a93-8485-4109-a136-4e51acf36022
ACCESS_KEY:azw!92$*!@#
STORAGE_ACCOUNT:storagecontainer
LOG_CONTAINER:refresh-logs
YML_CONTAINER:metadata
```

# Uruchamianie
Z uwagi na fakt, ze aplikacja zostala napisana dla wersji jezyka Powershell 7 (Core), moze zostac uruchomiona na windowsie/linuksie/macOs. Obecna struktura skryptu przewiduje codzienne odswiezanie wybranych tabel na modelu dwa razy dziennie. Zalecane jest stworzenie zadania cyklicznego w Task Schedulerze lub cronjoba o wysokiej czestotliwosci, tak, aby latwo dostosowac sie do ewentualnych zmian godzinowych w pliku .yml.
Skrypt przy kazdym uruchomieniu porownuje biezaca godzine ze wskazana godzina w pliku konfiguracyjnym i zaleznie od wyniku, rozpoczyna odswiezanie tabel badz konczy dzialanie.
