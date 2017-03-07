# Klarschiff-FieldService / Klarschiff-Aussendienst-Client
Klarschiff mobile client with additional functions supporting the field service

## Installation
### Voraussetzungen
- RVM / oder andere Rubyversionsverwaltung
  - Installation von RVM (kann übersprungen werden wenn diese bereits erfolgt ist):
  
    ```bash
    \curl -L https://get.rvm.io | sudo bash -s stable --ruby
    ```
  - Aktualisierung von RVM (falls es bereits systemweit installiert ist)
  
    ```bash
    rvmsudo rvm get stable
    ```
- Passenger-Apache-Modul installieren:
  Hierzu am besten der offiziellen Anleitung unter https://www.phusionpassenger.com/documentation/Users%20guide%20Apache.html#installation folgen.
  
### Vorbereitungen
- checkout / clone des Repositories in ein lokales Verzeichnis. Z.B.:

  ```bash
  sudo mkdir -p /var/rails
  cd /var/rails
  git clone https://github.com/bfpi/klarschiff-field_service.git
  ```
- Intitialisierung und Datenholung der Git-Submodule in dem gerade angelegtem Verzeichnis

  ```bash
  git submodule init
  git submodule update
  ```
- Installation der notwendigen Rubyversion und des Gemsets
  - Bei Wechsel in das Repository-Verzeichnis hilft RVM mit der Einrichtung
  - Gegebenenfalls muss das entsprechende Ruby installiert werden:
  
    ```bash
    rvm install ruby-2.2.2
    ```
  - Ein erneuter Wechsel in das Verzeichnis legt anschließend die notwendigen Wrapper und das Gemset an
  
    ```bash
    ruby-2.2.2 - #gemset created /usr/local/rvm/gems/ruby-2.2.2@klarschiff-field_service_r01
    ruby-2.2.2 - #generating klarschiff-field_service_r01 wrappers................
    ```
  - Falls ```bundler``` nicht (mehr) als Default-Gem durch RVM installiert wird, kann dies wie folgt nachgeholt werden:
  
    ```bash
    gem install bundler --no-ri --no-rdoc
    ```
  - Zur Installation der Gems für die Anwendung ist im Verzeichnis nun folgender Aufruf notwendig:
  
    ```bash
    bundle install
    ```
  - Zusätzliche Javascript-Bibliotheken werden wie folgt installiert:
  
    ```bash
    rake assets:libs
    ```
  
  - Precompilieren der Assets (Bilder, JS, Stylesheets)
  
    ```bash
    rake assets:precompile
    ```

## Konfiguration der Applikation (Anpassung an die entsprechende Umgebung / Unterscheidung zw. mobilem Simple-Client und mobilem Außendienst-Frontent)
Für die Konfigurationsdateien mit vertraulichem Inhalt gibt es versionierbare Vorlagen mit dem Namen `xyz.sample.yml`. Diese müssen kopiert und entsprechend ohne das `sample` als `yxz.yml` benannt werden.

### Konfigurationen in der `config/settings.yml`
  - LDAP erfolgt in dem Block `ldap`
  - URL zur Straßen- und Adresssuche im Frontend erfolgt im Block `global`
  - Resource-Servers (Verbindung zum CitySDK-Server) erfolgt im Block `resource_servers`
  - Konfiguration des entsprechenden Clients, den Außendienst-Client (Prüf- und Protokoll-Client, PPC) oder mobilen Client, erfolgt im Block `client`:
    - `key` (Pflichtfeld):
      - Kurzwort für die zugehörige Stadt/Gemeinde (z.B. hro, hgw, sn)
    - `login_required` (Pflichtfeld): 
      - wenn auf `true` gesetzt, wird der PPC konfiguriert, ansonsten der mobile Client
    - `name` (Pflichtfeld):
      - Name des Clients
    - `resources_path` (Pflichtfeld):
      - Pfad in dem die externen statischen Seiten (z.B. Hilfsseite, API) abgelegt wurden
    - `show_email`: 
      - steuert die Darstellung der e-Mail-Felder in den Formularen für Meldungen und interne Kommentare
      - auf `true` gesetzt, wenn der mobile Client konfiguriert ist und der Parameter nicht mit einem Wert belegt wurde
    - `show_abuses`:
      - steuert die Darstellung der `Missbrauch`-Schaltfläche für Meldungen
      - auf `true` gesetzt, wenn der mobile Client konfiguriert ist und der Parameter nicht mit einem Wert belegt wurde
    - `show_votes`:
      - steuert die Darstellung der Schaltfläche zum Unterstützen einer Meldung sowie die Anzahl der bisherigen Unterstützungen der Meldung
      - auf `true` gesetzt, wenn der mobile Client konfiguriert ist und der Parameter nicht mit einem Wert belegt wurde
    - `show_create_comments`:
      - steuert die Darstelling der Schaltfläche `Lob, Hinweise oder Kritik`
      - auf `true` gesetzt, wenn der mobile Client konfiguriert ist und der Parameter nicht mit einem Wert belegt wurde
    - `show_comments`:
      - steuert die Darstellung der Kommentare einer Meldung
      - auf `true` gesetzt, wenn der PPC konfiguriert ist und der Parameter nicht mit einem Wert belegt wurde
    - `show_edit_request`:
      - steuert die Darstellung der Bearbeiten-Schaltfläche einer Meldung
      - auf `true` gesetzt, wenn der PPC konfiguriert ist und der Parameter nicht mit einem Wert belegt wurde
    - `show_edit_status`:
      - steuert die Darstellung der Schaltfläche zum Ändern des Status eines Auftrags
      - auf `true` gesetzt, wenn der PPC konfiguriert ist und der Parameter nicht mit einem Wert belegt wurde
    - `show_protocol`:
      - steuert die Darstellung der Schaltfäche zur Erstellung eines KOD-Protokolls einer Meldung
      - auf `true` gesetzt, wenn der PPC konfiguriert ist und der Parameter nicht mit einem Wert belegt wurde
    - `show_notes`:
      - steuert die Dartsellung des Schaltfläche zur Erstellung und Anzeige von internen Kommentaren
      - auf `true` gesetzt, wenn der PPC konfiguriert ist und der Parameter nicht mit einem Wert belegt wurde
    - `show_trust`:
      - steuert die Darstelling der Trust-Level-Sterne
      - auf `true` gesetzt, wenn der PPC konfiguriert ist und der Parameter nicht mit einem Wert belegt wurde
  - Konfiguration der minimalen Anzahl von Unterstützungen für Meldungen vom Typ Idee erfolgt im Block `vote`

### Secrets (`config/secrets.yml`) zur Verschlüsselung der internen Nutzerdaten (Cookies, usw.)
Die Konfiguration erfolgt hier nach Rails-Konvention pro Umgebung. Es muss aber nur die Variante mit der entsprechenden Umgebung konfiguriert werden. Also `production` in der Produktivumgebung und der Demo-Umgebung. Die RAILS_ENV `test` ist für automatisierte Tests im Framework vorbehalten.

### URL-Umleitung und Direkt-Links

#### Änderungen der Konfiguration am Apache-Server
- folgende Änderungen an der .conf-Datei des Apache-Servers sind vorzunehmen
```php
  RewriteEngine on
```
- Aktivierung der RewriteEngine zum Umschreiben der angeforderten URL
```php
  RewriteCond %{REQUEST_URI} ^/$
  RewriteRule (.*) /mobil/start [R=301]
```
- Umschreiben der Basis-URI des Webservers auf das Start-Verzeichnis des mobilen Clients, auf dem die Umleitung erfolgt

```php
  Alias /resources path_to_resources
```
- Zugriff auf den Ordner, in dem die statischen Inhalte abgelegt wurden
- path_to_resources muss entsprechend mit dem Pfad ersetzt werden, in dem die statischen Inhalte liegen

#### URL-Umleitung
- über `<client_url>/start` erfolgt die Umleitung auf dem mobilen oder Desktop-Client, je nachdem, welches Gerät erkannt wurde
- beim PPC findet diese Umleitung nicht statt
- zudem kann der Query-Parameter `advice=<id>` übergeben werden, mit dem nach Weiterleitung auf den entsprechenden Client die Meldung mit der angegebenen `id` aufgerufen wird

#### Direkt-Links
- mittels `<client_url>/?request=<id>` kann direkt auf eine Meldung mit der entsprechenden `id` zugegriffen werden, sofern diese existiert
- die Karte zentriert dabei auf die Meldung und stellt diese dar
