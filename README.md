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
    rvm install ruby-2.3.2
    ```
  - Ein erneuter Wechsel in das Verzeichnis legt anschließend die notwendigen Wrapper und das Gemset an
  
    ```bash
    ruby-2.3.2 - #gemset created /usr/local/rvm/gems/ruby-2.3.2@klarschiff-field_service_r01
    ruby-2.3.2 - #generating klarschiff-field_service_r01 wrappers................
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

## Konfiguration der Applikation (Anpassung an die entsprechende Umgebung / Unterscheidung zw. mobilem Simple-Client und mobilem Außendienst-Frontend)
Für die Konfigurationsdateien mit vertraulichem Inhalt gibt es versionierbare Vorlagen mit dem Namen `xyz.sample.yml`. Diese müssen kopiert und entsprechend ohne das `sample` als `xyz.yml` benannt werden. Die für die Umgebung gültigen Werte werden dann in der `xyz.yml` konfiguriert.

### Konfigurationen in der `config/settings.yml`

#### Block 'urls'
Zentrale Konfiguration von im Frontend genutzten URLs.
  - `ks_server_url` (Pflichtfeld):
    - URL zum Klarschiff-Frontend
  - `ks_backend_vorgang_url` (Pflichtfeld):
    - URL zum Vorgang in der Backend-Anwendung
  - `ks_demo_url` (Pflichtfeld):
    - URL zur Demo-Installation
  - `ks_github_url` (Pflichtfeld):
    - URL zum GIT-Repository des Klarschiff-Frontents
  - `font_origin_url` (Pflichtfeld):
    - URL zur Font-Quelle
  - `font_license_url` (Pflichtfeld):
    - URL zur Font-Lizenz

#### Block 'client'
Konfiguration des entsprechenden Clients, den Außendienst-Client (Prüf- und Protokoll-Client, PPC) oder mobilen Client:
  - `animate_refresh` (Pflichtfeld):
    - Zeitabstand (in Sekunden) zwischen der letzten und der nächsten Animation für den "Neue Meldung"-Marker
  - `service_code` (optional):
    - ID der Unterkategorie, auf die die Funktionalitäten des PC-Clients beschränkt werden sollen
  - `key` (Pflichtfeld):
    - Kurzwort für die zugehörige Stadt/Gemeinde (z.B. hro, hgw, sn)
  - `login_required` (Pflichtfeld):
    - wenn auf `true` gesetzt, wird der PPC konfiguriert, ansonsten der mobile Client
  - `multi_requests_enabled` (optional):
    - ermöglicht das Anlegen von Multimeldungen (Es werden einzelne "normale" Meldungen erzeugt, welche in den wesentlichen Eigenschaften identisch sind, allerdings unterschiedlichen Kategorien zugeordnet sind. Diese verbleiben nach der Erstellung vollständig eigentständig)
  - `name` (Pflichtfeld):
    - Name des Clients
  - `city_long` (Pflichtfeld):
    - Name der Stadt
  - `city_short` (Pflichtfeld):
    - Name der Stadt in Kurzform
  - `resources_path` (Pflichtfeld):
    - Pfad in dem die externen statischen Seiten (z.B. Hilfsseite, API) abgelegt wurden
  - `resources_overview_path` (Pflichtfeld):
    - Pfad in dem die automatisch generierten statischen Dateien der Vorgangslisten abgelegt wurden
  - `logo_url` (Pflichtfeld):
    - Pfad zum Gemeinde-Logo
  - `show_email` (optional):
    - steuert die Darstellung der e-Mail-Felder in den Formularen für Meldungen und interne Kommentare
    - auf `true` gesetzt, wenn der mobile Client konfiguriert ist und der Parameter nicht mit einem Wert belegt wurde
  - `show_abuses` (optional):
    - steuert die Darstellung der `Missbrauch`-Schaltfläche für Meldungen
    - auf `true` gesetzt, wenn der mobile Client konfiguriert ist und der Parameter nicht mit einem Wert belegt wurde
  - `show_votes` (optional):
    - steuert die Darstellung der Schaltfläche zum Unterstützen einer Meldung sowie die Anzahl der bisherigen Unterstützungen der Meldung
    - auf `true` gesetzt, wenn der mobile Client konfiguriert ist und der Parameter nicht mit einem Wert belegt wurde
  - `show_create_comments` (optional):
    - steuert die Darstellung der Schaltfläche `Lob, Hinweise oder Kritik`
    - auf `true` gesetzt, wenn der mobile Client konfiguriert ist und der Parameter nicht mit einem Wert belegt wurde
  - `show_comments` (optional):
    - steuert die Darstellung der Kommentare einer Meldung
    - auf `true` gesetzt, wenn der PPC konfiguriert ist und der Parameter nicht mit einem Wert belegt wurde
  - `show_edit_request` (optional):
    - steuert die Darstellung der Bearbeiten-Schaltfläche einer Meldung
    - auf `true` gesetzt, wenn der PPC konfiguriert ist und der Parameter nicht mit einem Wert belegt wurde
  - `show_edit_status` (optional):
    - steuert die Darstellung der Schaltfläche zum Ändern des Status eines Auftrags
    - auf `true` gesetzt, wenn der PPC konfiguriert ist und der Parameter nicht mit einem Wert belegt wurde
  - `show_protocol` (optional):
    - steuert die Darstellung der Schaltfäche zur Erstellung eines KOD-Protokolls einer Meldung
    - auf `true` gesetzt, wenn der PPC konfiguriert ist und der Parameter nicht mit einem Wert belegt wurde
  - `show_notes` (optional):
    - steuert die Dartsellung der Schaltfläche zur Erstellung und Anzeige von internen Kommentaren
    - auf `true` gesetzt, wenn der PPC konfiguriert ist und der Parameter nicht mit einem Wert belegt wurde
  - `show_trust` (optional):
    - steuert die Darstelling der Trust-Level-Sterne
    - auf `true` gesetzt, wenn der PPC konfiguriert ist und der Parameter nicht mit einem Wert belegt wurde
  - `show_d3_document_url` (optional):
    - steuert die Dartsellung der Schaltfläche zum Aufruf der Vorgangs-Akte im d.3-Client
    - auf `true` gesetzt, wenn der PPC konfiguriert ist und der Parameter nicht mit einem Wert belegt wurde
  - `additional_content` (Pflichtfeld):
    - hier kann zusätzliches HTML eingetragen werden (z.B. Piwik-Code) welches dann als letztes innerhalb des HTML-Body ausgegeben wird.
    - auf `false` gesetzt, wenn kein zusätzliches HTML notwendig ist

#### Block 'vote'
  - `min_requirement` (Pflichtfeld):
    - Konfiguration der minimalen Anzahl von Unterstützungen für Meldungen vom Typ Idee

#### Block 'ldap'
  - `host` (Pflichtfeld für PPC):
    - LDAP Host
  - `port` (Pflichtfeld für PPC):
    - LDAP Port
  - `encryption` (Pflichtfeld für PPC):
    - Festlegen von Verschlüsselungseigenschaften (simple_tls oder :start_tls)
  - `username` (Pflichtfeld für PPC):
    - LDAP Benutzername
  - `password` (Pflichtfeld für PPC):
    - LDAP Passwort
  - `users` (Pflichtfeld für PPC):
    - `attributes_mapping` (Pflichtfeld für PPC):
      - LDAP-Attribute der Benutzer, die ausgelesen werden sollen
    - `base` (Pflichtfeld für PPC):
      - Einschränkung auf LDAP-Suchbasis für Benutzer
  - `groups` (Pflichtfeld für PPC):
    - `base` (Pflichtfeld für PPC):
      - Einschränkung auf LDAP-Suchbasis für Gruppen
    - `search_pattern` (Pflichtfeld für PPC):
      - Such-Pattern für die Suche von Gruppen

#### Block 'resource_servers'
  - `city_sdk` (Pflichtfeld):
    - `site`
      - Pfad zum CitySDK-Server
    - `format`
      - Format der Kommunikation (json oder xml)
    - `api_key`
      - API-Key zur Authentifizierung des Clients

#### Block 'address_search'
Konfiguration der Adressensuche:
  - `url` (Pflichtfeld):
    - URL zur Adressensuche
  - `api_key` (Pflichtfeld):
    - API-Key für Adressensuche
  - `localisator` (optional):
    - String zur Voreingrenzung der Resultate der Adressensuche (z.B. `rostock`, um Resultate der Adressensuche auf Rostock voreinzugrenzen)

#### Block 'protocol_mail'
  - `recipient` (Pflichtfeld für PPC):
    - E-Mail-Empfänger der Protokoll-Benachrichtigungen
  - `sender` (Pflichtfeld für PPC):
    - E-Mail-Absender an Protokoll-Benachrichtigungen
  - `smtp` (Pflichtfeld für PPC):
    - `host` (Pflichtfeld für PPC):
      - E-Mail-Server
    - `starttls_enabled` (Pflichtfeld für PPC):
      - aktiviert die Erkennung, ob der SMTP-Server STARTTLS aktiviert hat und verwendet es
    - `username` (Pflichtfeld für PPC):
      - E-Mail Benutzername
    - `password` (Pflichtfeld für PPC):
      - E-Mail Passwort

#### Block 'map'
  - Konfiguration der Karten-Layer (ein Beispiel ist in der `config/settings.sample.yml` zu finden

#### Block 'request'
  - `permissable_states` (Pflichtfeld für PPC):
    - Einschränkung auf erlaubte Status

#### Block 'auto_refresh'
  - `timeout` (Pflichtfeld):
    - Automatisches Aktualisieren der Vorgänge alle X ms

### Konfigurationen in der `config/secrets.yml`
Diese Datei dient der Konfiguration zur Verschlüsselung der internen Nutzerdaten (Cookies, usw.).
  - Die Konfiguration erfolgt hier nach Rails-Konvention pro Umgebung. Es muss aber nur die Variante mit der entsprechenden Umgebung konfiguriert werden. Also `production` in der Produktivumgebung und der Demo-Umgebung. Die RAILS_ENV `test` ist für automatisierte Tests im Framework vorbehalten.

### Precompilieren der Assets (Bilder, JS, Stylesheets)
```bash
rake assets:precompile
```

### Konfiguration am Apache-Server
Für die einfachere Verwaltung und den parallelen Betrieb mehrerer Klarschiffinstanzen werden die statischen (sich unterscheidenden) Inhalte in einen zusätzlichen Ressourcen-Verzeichnis abgelegt.
Dieses Verzeichnis wird in der `settings.yml` für die Anwendung konfiguriert. Damit dieses harmonisch funktioniert muss zusätzlich ein Alias dafür im Apache-Server (in der .conf Datei) konfiguriert werden:
```php
  Alias /resources path_to_resources
```
`path_to_resources` muss entsprechend mit dem Pfad ersetzt werden, in dem die statischen Inhalte liegen.

### Hinweise zu automatischen URL-Umleitungen und Direkt-Links
#### URL-Umleitung
- Beim Aufruf der Anwendung über die jeweilige `<root_url>` der Instanz erfolgt automatisch eine Umleitung auf dem mobilen oder Desktop-Client, je nachdem, welches Gerät erkannt wurde.
- Handelt es sich bei der eingerichteten Instanz um den PPC findet diese Umleitung nicht statt, da dieser direkt als mobile Anwendung vorkonfiguriert ist.
- Wird die Anwendung mit dem Query-Parameter `advice=<id>` aufgerufen, erfolgt nach der Weiterleitung auf den entsprechenden Client die Anzeige der Meldung zur angegebenen `id` (siehe dazu auch den Abschnitt Direkt-Links).

#### Direkt-Links
- Mittels `<root_url>/map?request=<id>` kann direkt auf eine Meldung mit der entsprechenden `id` zugegriffen werden, sofern diese existiert.
- Die Anwendung schaltet dazu auf die Karte, zentriert auf die Meldung, und stellt diese dar.
