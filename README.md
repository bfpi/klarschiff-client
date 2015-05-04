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

### Vorbereitungen
- checkout / clone des Repositories in ein lokales Verzeichnis:

  ```bash
  sudo mkdir -p /var/rails
  cd /var/rails
  git clone https://github.com/bfpi/klarschiff-field_service.git
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
  - Passenger-Apache-Modul installieren
  
    ```bash
    passenger-install-apache2-module
    ```
    Die Ausgabe dieses Vorgangs lierfert die Angaben für die Integration in der Apache-Konfiguration. Z.B.:
    
    ```
    LoadModule passenger_module /usr/local/rvm/gems/ruby-2.2.2@klarschiff-field_service_r01/gems/passenger-5.0.6/buildout/apache2/mod_passenger.so
    <IfModule mod_passenger.c>
      PassengerRoot /usr/local/rvm/gems/ruby-2.2.2@klarschiff-field_service_r01/gems/passenger-5.0.6
      PassengerDefaultRuby /usr/local/rvm/gems/ruby-2.2.2@klarschiff-field_service_r01/wrappers/ruby
    </IfModule>
    ```
  - Precompilieren der Assets (Bilder, JS, Stylesheets)
  
    ```bash
    rake assets:precompile
    ```
- Konfiguration der Applikation (Anpassung an die entsprechende Umgebung)
  - Für die Konfigurationsdateien mit vertraulichem Inhalt gibt es versionierbare Vorlagen mit dem Namen `xyz.sampla.yml`. Diese müssen kopiert und entsprechend ohne das `sample` als `yxz.yml` bennant werden.
  - LDAP erfolgt in der Datei `config/settings.yml`, in dem Block `ldap`
  - Secrets
  - Resource-Servers
