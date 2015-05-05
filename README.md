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
- Konfiguration der Applikation (Anpassung an die entsprechende Umgebung)
  - Für die Konfigurationsdateien mit vertraulichem Inhalt gibt es versionierbare Vorlagen mit dem Namen `xyz.sample.yml`. Diese müssen kopiert und entsprechend ohne das `sample` als `yxz.yml` bennant werden.
  - Konfigurationen in der `config/settings.yml`
    - LDAP erfolgt in dem Block `ldap`
    - URL zur Straßen- und Adresssuche im Frontend erfolgt im Block `global`
    - Resource-Servers (Verbindung zum CitySDK-Server) erfolgt im Block `resource_servers`
  - Secrets (`config/secrets.yml`) zur Verschlüsselung der internen Nutzerdaten (Cookies, usw.)
    - Die Konfiguration erfolgt hier nach Rails-Konvention pro Umgebung. Es muss aber nur die Variante mit der entsprechenden Umgebung konfiguriert werden. Also `production` in der Produktivumgebung, `consolidation` in der Demo-Umgebung, usw.
  - 
  
