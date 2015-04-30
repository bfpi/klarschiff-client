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
  - Zur Installation der Gems für die Anwendung ist im Verzeichnis nun folgender Aufruf notwendig:
  
    ```bash
    bundle install
    ```
  - Zusätzliche Javascript-Bibliotheken werden wie folgt installiert:
  
    ```bash
    rake assets:libs
    ```
