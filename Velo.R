# ———
# Datenanalyse mit R am Beispiel der Zürcher Velo-Verkehrszählungen
# ———
# Das Wichtigste:
# ———
# Wenn Sie das Dokument mit RStudio öffnen sehen Sie vier Bereiche
# Hier (oben links) ist die geöffnete Datei. Darunter ist die
# Konsole. Darin wird der Code ausgeführt. Auf der Rechten Seite
# sind noch ein paar sachen mehr. Zum Beispiel die Hilfe oder die
# Umgebungsvariablen (Bisher noch leer aber das ändert sich bald)
# 
# Code wird ausgeführt indem er an die Konsole geschickt wird.
# Drücken Sie cmd + Enter (Mac) oder ctrl + Enter (Windows) um 
# jeweils die Zeile auszuführen in der sich der Curser befindet.
# ———
# Schritt 1: Arbeitsbereich einrichten
# ———
# Mit dem Befehl setwd(…) wird das working directory festgelegt.
# Geben Sie hier den Pfad zum Projektordner an um später die CSV
# Dateien importieren zu können.
#
# Auf dem Mac sieht der Pfad zum Beispiel so aus: "~/Desktop/Velo"
# auf Windows so: "C:/Users/Fidel/Desktop/Velo". Drücken Sie Tab in
# den Anführungszeichen um verfügbare Ordner anzuzeigen

setwd("~/Desktop/SSZ/Open Data/Sachen Machen/R/Velo/")

# Alternativ dazu können Sie in RStudio unter File -> New Project
# -> Existing Directory diesen Ordner auswählen. Wenn Sie die darin
# erstellte .Rproj Datei öffnen, wird das entsprechende Verzeichnis
# automatisch gesetzt.

# ———
# Schritt 2: Daten importieren
# ———
# Als erstes die Zähldaten: Mit read.csv(…) lesen Sie CSV-Dateien
# ein. Mit <- weisen Sie die Daten der voranstehenden Variable zu

verkehr <- read.csv("2015_verkehrszaehlungen_werte_fussgaenger_velo.csv")

# Bei den Standorten sind die Werte mit Semikolons anstatt Kommas
# getrennt, daher muss der Seperator angegeben werden.

standorte <- read.csv("verkehrszaehlungen_standorte_velo_fussgaenger.csv", sep = ";")

# ———
# Schritt 3: Aufräumen
# ———
# Wie sehen die Daten überhaupt aus? Mit head(…) kann man sich die
# ersten paar Spalten eines Datensatzes anzeigen lassen

head(verkehr)

# Der Datensatz hat 7 Spalten. Die ObjectID ist eine unique ID für
# jede Beobachtung. Eigentlich brauchen wir die nicht. Also löschen
# wir die spalte indem wir ihr NULL zuweisen. Über das Dollar-
# Zeichen gelangen wir an die Spalte:

verkehr$ObjectID <- NULL

# Damit R das Datum auch als Datum versteht müssen wir es parsen.
# Das geht mit as.POSIXct(…), dem Befehl müssen die Daten
# (verkehr$Datum), die Zeitzone (Europe/Zurich) und das Datums-
# format mitgegeben werden.

verkehr$Datum <- as.POSIXct(verkehr$Datum, "Europe/Zurich", "%Y-%m-%dT%H:%M:%S")

# Anhand des Codes unter Standort können wir den Datensatz nacher
# mit den Standorten zusammenführen.

# Jetzt kommen wir zu den eigentlichen Zählwerten der Stationen.
# Da gibt es vier Spalten. Velo und Fussgänger, jeweils stadtein-
# und stadtauswärts. Manche Stationen messen alles, andere nur
# Velos oder Fussgänger (Daher NA, was für ‘Not Available’ steht)
# Bei den Velos gibt es ausserdem noch zwei Ausnahmen die nur eine
# Richtung messen. Die Fussgänger interessieren uns nicht. Also:

verkehr$Fuss_in <- verkehr$Fuss_out <- NULL

# Zwar haben wir die Spalten gelöscht, im Datansatz sind aber immer
# noch Beobachtungen ohne Werten für die Velozählungen. Um zu über-
# prüfen, ob ein Wert NA ist gibt's is.na(…)

is.na(10) # Gibt FALSE Zurück
is.na(NA) # Gibt TRUE Zurück

# solche Abfragen lassen sich auch auf Tabellenspalten anwenden
# (Ich verwende wieder head(…) um nur die ersten sechs Ergebnisse
# anzuzeigen)

head(is.na(verkehr$Velo_in))

# Damit möchten wir jetzt den Datensatz filtern. Das geht so:
# Bisher haben wir das Dollar-Zeichen verwendet um an die Werte in
# einer Spalte zu gelangen. Dafür gäbe es auch diese Schreibweise:

head(verkehr[,"Datum"])

# Mit den eckigen Klammern kann man aber noch viel mehr machen.
# Schreibt man vor die Klammer eine 1, so wird nur der Wert in der
# ersten Zeile zurückgegeben

verkehr[1,"Datum"]

# Lassen wir "Datum" weg erhalten wir die gesamte erste Zeile

verkehr[1,]

# Um an mehrere Zeilen zu gelangen kann man anstatt einer Zahl
# einen Vector mit mehreren Zahlen einsetzen. Einen Vector erstellt
# man mit c(…)

verkehr[c(1,2,100),] # gibt die erste, zweite und 100. Zeile zurück

# Anstatt die Zeilen über deren Nummer auszuwählen, kann der Vector
# auch mit Booleans (TRUE oder FALSE) gefüllt werden. Das folgende
# Beispiel gibt nur noch jede zweite Zeile zurück, da der zweite
# Wert FALSE ist:

head(verkehr[c(TRUE,FALSE),])

# So einen Vektor mit TRUEs und FALSEs haben wir vorher mit 
# is.na(verkehr$Velo_in) bekommen. Also:

head(verkehr[is.na(verkehr$Velo_in),])

# Das sind die Zeilen ohne Werte. Wir wollen die anderen. Mit einem
# Ausrufezeichen lassen sich Booleans umkehren:

!FALSE # Gibt TRUE Zurück
!TRUE # Gibt False Zurück

# Das vor is.na(…):

head(verkehr[!is.na(verkehr$Velo_in),])

# Damit überschreiben wir jetzt (ohne head(…), da wir ja alle Werte
# haben wollen) die Variable Verkehr:

verkehr <- verkehr[!is.na(verkehr$Velo_in),]

# ———
# Jetzt noch die Standorte anschauen
# ———

head(standorte)

# ABKUERZUNG, BIS und VON brauchen wir nicht, also weg damit:

standorte$ABKUERZUNG <- standorte$BIS <- standorte$VON <- NULL

# Aus irgendeinem Grund hat die zweite Station, die nur in eine 
# Richtung misst "---" drin stehen. Wir wollen da nichts haben:

standorte[5,"RICHTUNG_O"] <- ""

# In diesem PDF https://data.stadt-zuerich.ch/storage/f/verkehrszaehlungen_werte_fussgaenger_velo/15_12_15_Korrekturfaktoren_VZS_OGD_Veloverkehr.pdf
# stehen Korrekturfaktoren für die Stationen drin. Damit wir die
# später anwenden können wollen wir die auch bei den Standorten
# dabei haben. Bei allen Stationen die Velos messen fügen wir eine
# neue Spalte "korrektur" hinzu. Und weisen den den entsprechenden
# Korrekturfaktor hinzu. Das ist mühsame Handarbeit:

standorte[standorte$BEZEICHNUN == "Andreasstrasse","Korrektur"] <- 1.14
standorte[standorte$BEZEICHNUN == "Militärbrücke","Korrektur"] <- 0.96
standorte[standorte$BEZEICHNUN == "Bertastrasse","Korrektur"] <- 1.25
standorte[standorte$BEZEICHNUN == "Mühlebachstrasse","Korrektur"] <- 1.3
standorte[standorte$BEZEICHNUN == "Binzmühlestrasse","Korrektur"] <- 1.2
standorte[standorte$BEZEICHNUN == "Mythenquai","Korrektur"] <- 1.2
standorte[standorte$BEZEICHNUN == "Bucheggplatz","Korrektur"] <- 1.25
standorte[standorte$BEZEICHNUN == "Saumackerstrasse","Korrektur"] <- 1.23
standorte[standorte$BEZEICHNUN == "Fischerweg","Korrektur"] <- 1.0
standorte[standorte$BEZEICHNUN == "Scheuchzerstrasse","Korrektur"] <- 1.06
standorte[standorte$BEZEICHNUN == "Hofwiesenstrasse","Korrektur"] <- 1.33
standorte[standorte$BEZEICHNUN == "Schulstrasse","Korrektur"] <- 1.37
standorte[standorte$BEZEICHNUN == "Kloster-Fahr-Weg","Korrektur"] <- 1.09
standorte[standorte$BEZEICHNUN == "Sihlpromenade","Korrektur"] <- 1.10
standorte[standorte$BEZEICHNUN == "Langstrasse (Unterführung West)","Korrektur"] <- 0.95
standorte[standorte$BEZEICHNUN == "Talstrasse","Korrektur"] <- 1.35
standorte[standorte$BEZEICHNUN == "Limmatquai, Ri. Bellevue","Korrektur"] <- 1.52
standorte[standorte$BEZEICHNUN == "Tödistrasse","Korrektur"] <- 1.37
standorte[standorte$BEZEICHNUN == "Limmatquai, Ri. Central","Korrektur"] <- 1.35
standorte[standorte$BEZEICHNUN == "Zollstrasse","Korrektur"] <- 1.43
standorte[standorte$BEZEICHNUN == "Lux-Guyer-Weg","Korrektur"] <- 1.04

# Bei den anderen Zählstellen steht in der SPalte jetzt NA, wir
# könnten das wieder löschen. Wenn wir im nächsten Schritt beide
# Datensätze zusammenführen, fallen die aber ohnehin raus.

# ———
# Schritt 4: MERGE!!!
# ———
# Zum zusammenführen der Datensätze gibt's merge(…). Wir geben an,
# welche Datensätze gemerget werden sollen und anhand welcher 
# Spalten das passieren soll

velos <- merge(verkehr, standorte, by.x = "Standort", by.y = "FK_ZAEHLER")

# Das sieht dann so aus:

head(velos)

# Mit den zusammengeführten Tabellen können wir jetzt super ein-
# fach die Korrekturen anwenden. Wir müssen nur die beiden Spalten
# Velo_in und Velo_out mit der Korrektur mutliplizieren

velos$Velo_in <- velos$Velo_in * velos$Korrektur
velos$Velo_out<- velos$Velo_out * velos$Korrektur

# Genuaso können wir auch eine neue Spalte mit den summierten Velo-
# zählungen machen.

velos$Velo_total <- velos$Velo_in + velos$Velo_out

# Einige Zählstellen messen aber nur eine Richtung, bei denen ist
# der Wert Velo_out NA. Und 10 + NA = NA. Bei allen Zeilen, bei
# denen Velo_total jetzt NA ist, wollen wir stattdessen den Wert
# von Velo_in haben:

velos[is.na(velos$Velo_total),"Velo_total"] <- velos[is.na(velos$Velo_total),"Velo_in"]

# ———
# Schritt 5: Exploration
# ———
# Einen kleinen Einblick in die Daten bekommen wir mit summary(…).

summary(velos$Velo_total)

# Ein wirkliches Bild von den Daten bekommen wir aber erst, wenn
# wir uns einen Graph zeichnen. Das geht zum Beispiel mit plot(…).
# Dabei geben wir die Spalten Datum und Velo_total als Werte für
# die X- und Y-Achse an. (Das kann jetzt etwas dauern…)

plot(velos$Datum,velos$Velo_total)

# Hmm… Das sind 724 108 Kreise die sich grösstenteils überlagern,
# nicht wirklich Aussagekräftig. Veruschen wir was anderes:
#
# Der Funktionsumfang von R lässt sich mit Packages erweitern. 
# Davon gibt es etliche, für das Zeichnen von Graphen ist ggplot2
# weit verbreitet. Packages muss man einerseits installieren mit
# install.packages(…) und dann noch laden mit require(…). Ersteres
# muss man nur einmal machen, letzteres in jedem Code, wo man das
# Package benötigt. 
#
# Da man nicht immer weiss welche Packages man (oder jemand anderes,
# dem man den Code später gibt) bereits installiert hat, empfielt
# sich die folgende Schreibweise. Sie versucht das package zu
# laden, und falls das nicht klappt wird es installiert.

if(!require(ggplot2)) {
  install.packages("ggplot2")
  require(ggplot2)
}

# ggplot2 basiert auf "the grammar of graphics". Das heisst es ist
# modular aufgebaut. Im ersten Teil ggplot(…) gebe ich die Daten, 
# zuerst den Datensatz und dann die Spalten, an. Mit geom_point(…)
# Sage ich, dass ich einen Dotplot zeichnen möchte. Das + verbindet
# die zwei Teile:

ggplot(velos, aes(Datum, Velo_total)) + geom_point()

# Da ist jetzt immer noch viel Überlagerung, ein paar Dinge können
# wir aber schon erkennen: Im Februar scheint weniger los zu sein,
# über Weihnachten und bis Silvester ist auch nicht viel. Die 
# hohen Werteam 1. Januar sind merkwürdig (wenn das stimmt wär das
# über 15 Minuten alle 2 Sekunden ein Velo. Und die sehr regel-
# mässigen Einschnitte bedeuten vermutlich das am Wochenende stets
# weniger los ist.
#
# Um mehr zu erkennen müssen wir die Anzahl der Daten reduzieren. 
# Das machen wir in dem wir die Daten aggregieren. Als erstes 
# schauen wir uns die Gesamtwerte der einzelnen Stationen an.
# Das geht mit aggregate(…). Dabei geben wir an, welche Spalte wir
# aggregieren, danach bei welcher wir die Werte gruppieren wollen.
# Der letzte parameter sagt, das die Werte von velos$Velo_total
# summiert werden sollen (andere Optionen wären z.B. mean oder max)

stationen_gesamt <- aggregate(velos$Velo_total, by = list(velos$BEZEICHNUN), FUN = sum)

# so sieht's aus:

head(stationen_gesamt)

# Da die Spaltennamen nicht übernommen wurden, passen wir das an:

names(stationen_gesamt) <- c("BEZEICHNUN", "Velo_total")

# Und zeichnen das als Balkendiagramm:

ggplot(stationen_gesamt, aes(BEZEICHNUN, Velo_total)) + geom_bar(stat = "identity")

# Oh, da gibt es grosse Unterschiede. Schade bloss das wir die
# Standorte nicht lesen können. coord_flip() hilft:

ggplot(stationen_gesamt, aes(BEZEICHNUN, Velo_total)) + geom_bar(stat = "identity") + coord_flip()

# Ordnen wir die Daten nach velo_total, wird's noch übersichtlicher

ggplot(stationen_gesamt, aes(reorder(BEZEICHNUN, Velo_total), Velo_total)) + geom_bar(stat = "identity") + coord_flip()

# Genauso können wir die Daten auch nach Datum aggregieren

datum_gesamt <- aggregate(velos$Velo_total, by = list(velos$Datum), FUN = sum)
names(datum_gesamt) <- c("Datum","Velo_total")
ggplot(datum_gesamt, aes(Datum, Velo_total)) + geom_line()

# Hm, das bringt nicht so viel. sinnvoll wären die Daten Tagesweise
# aggregiert nicht auf 15 Minuten Zeitspannen. Dafür holen laden
# wir ein weiteres Package:

if(!require(lubridate)) {
  install.packages("lubridate")
  require(lubridate)
}

# lubridate bietet viele Funktionen, die es erleichtern mit Datum
# und Zeit zu arebiten. Mit floor_date(…) lassen sich Datumsangaben
# abrunden. Wir wollen eine neue Spalte, in der nur das Datum ohne
# Uhrzeit steht:

velos$Datum_Tag <- floor_date(velos$Datum, unit = "day")
# wieder aggregieren

datum_gesamt <- aggregate(velos$Velo_total, by = list(velos$Datum_Tag), FUN = sum)
names(datum_gesamt) <- c("Datum_Tag","Velo_total")
ggplot(datum_gesamt, aes(Datum_Tag, Velo_total)) + geom_line()

# Das sieht schon besser aus. Es gibt sehr starke Unterschiede, 
# im Sommer gibt's aber auf jeden Fall schon deutlich mehr Velos.
# Noch klarer wird das, zwichnet man eine durchschnittliche Linie
# durch die Punkte:

ggplot(datum_gesamt, aes(Datum_Tag, Velo_total)) + geom_line() + geom_smooth()

# Oh, das ist übrigens das tolle an ggplot2, ich kann auch mehrere
# Graphen aneinanderhängen:

ggplot(datum_gesamt, aes(Datum_Tag, Velo_total)) + geom_line() + geom_smooth() + geom_point(size=1, color = "#44ee99")

# Aber zurück zu den Daten: Wie sieht denn ein durchschnittlicher
# Tagesverlauf aus? Das ist etwas Gebastel: Um die Daten nach Uhr-
# zeit aggregieren zu können, müssen wir die Uhrzeit aus dem Datum
# extrahieren und daraus ein neues Datum erstellen, wobei überall
# der gleiche Tag (z.B. der 1.1.2015) stehen muss. Wir fügen die
# teile mit dem Befehl pate0(…) aneinander und parsen das Datum.

velos$Uhrzeit <- as.POSIXct(paste0("2015-01-01 ", hour(velos$Datum), ":", minute(velos$Datum)), "Europe/Zurich")

# Das aggregieren wir (diesmal mit mean anstatt sum)

uhrzeit_gesamt <- aggregate(velos$Velo_total, by = list(velos$Uhrzeit), FUN = mean)
names(uhrzeit_gesamt) <- c("Uhrzeit","Velo_total")

# Und Zeichnen!

ggplot(uhrzeit_gesamt, aes(Uhrzeit, Velo_total)) + geom_line()

# Die Labels zeigen auch das vorher gesetzte Datum an. Das ist
# Quatsch. Das Package scales lässt uns das anpassen 

if(!require(scales)) {
  install.packages("scales")
  require(scales)
}

ggplot(uhrzeit_gesamt, aes(Uhrzeit, Velo_total)) + geom_line() +
  scale_x_datetime(labels=date_format("%H:%M Uhr", tz= "Europe/Zurich"))

# Die Anzahl der Velos ist stark von den üblichen Arbeitszeiten
# abhängig. Auch über Mittag gibt es eine kleine Zunahme. Wahr-
# scheinlich gibt's da grössere Unterschiede zwischen den Wochen-
# tagen. Um das herauszufinden müssen wir die Daten nicht wie 
# bisher an einer Spalte aggregieren, sondern nach Uhrzeit und
# Wochentag. Als erstes fügen wir aber den Wochentag als neue
# Spalte hinzu:

velos$Wochentag <- wday(velos$Datum)

# Zum Aggregieren müssen wir eine andere Schreibweise von
# aggregate(…) verwenden. Der erste Parameter ist eine formula.
# Auf der linken Seite ist der Wert dessen Durchschnitt wir haben
# wollen. Rechts sind die beiden Spalten Wochentag und Uhrzeit. Da
# das nur die Spaltennamen sind, müssen wir zusätzlich noch den 
# Datensatz angebeben.

uhrzeit_wochentag <- aggregate(Velo_total ~ Wochentag + Uhrzeit, data=velos, mean)

# Fügen wir color=factor(Wochentag)) zu aes(…) hinzu, zeichnen wir
# für jeden Wochentag eine eigene Linie in einer anderen Farbe.

ggplot(uhrzeit_wochentag, aes(Uhrzeit, Velo_total, color=factor(Wochentag))) +
  geom_line() +
  scale_x_datetime(labels=date_format("%H:%M Uhr", tz= "Europe/Zurich"))

# Wir sehen, dass Am Wochenende (Wochentag 7 und 1) tatsächlich 
# deutlich weniger Velos unterwegs sind, dafür aber bis tiefer in
# die Nacht. Auffällig ist auch, dass bereits am Freitag etwas
# weniger los ist und das, je weiter die Woche voranschreitet, 
# desto später sind noch Velos unterwegs. Statt den Zahlen für die
# Wochentage haben wir aber doch lieber deren Namen. Dafür geben
# wir bei color unsere eigenen Labels mit:

ggplot(uhrzeit_wochentag, aes(Uhrzeit, Velo_total, color=factor(Wochentag, labels= c("Sonntag","Montag","Dienstag","Mittwoch","Donnerstag","Freitag","Samstag")))) +
  geom_line() + 
  scale_x_datetime(labels=date_format("%H:%M Uhr", tz= "Europe/Zurich")) + 
  labs(color = "Wochentag")

# Den Unterschied zwischen Arbeitstagen und Wochenenden haben wir
# als einen der Gründe für die starken Schwankungen in den Velo-
# zählungen ausgemacht. Schauen wir uns das nochmal im Jahresver-
# lauf an.

datum_gesamt$tag <- "Arbeitstag"
datum_gesamt[wday(datum_gesamt$Datum_Tag) == 1 | wday(datum_gesamt$Datum_Tag) == 7, "tag"] <- "Wochenende"

ggplot(datum_gesamt, aes(Datum_Tag, Velo_total, color=factor(tag))) +
  geom_line()

# Auch mit der Trennung von Arbeitstagen und Wochenende bleiben
# Schwankungen nicht aus. Die Vermutung liegt nahe, dass das mit
# dem Wetter zusammenhängt. Die Wetterdaten für 2015 finden wir
# (etwas versteckt in den Luftqualitätsmessungen) im Open Data
# Katalog: https://data.stadt-zuerich.ch/dataset/luftqualitaet-historisierte-messungen/resource/7d069e56-86e9-44bf-9702-390a8e517564
#
# Wir könnten wieder das CSV herunterladen und mit read.csv()
# laden, mit dem Package RCurl können wir die Datei aber auch
# direkt vom Katalog laden. Das ist besonders nützlich bei Daten-
# sätzen die regelmässig aktualisert werden (z.B. die Stündlich 
# aktualisierten Luftqualitätsmessungen).

if(!require(RCurl)) {
  install.packages("RCurl")
  require(RCurl)
}

# RCurl stellt die Funktion getURL(…) bereit, mit der sich Daten
# von einer URL laden lassen. Mitanzugeben ist dabei das Datei-
# Encoding, UTF-8 ist dabei meist eine gute Wahl.

luftqualität <- read.csv(sep = ";", text = getURL("https://data.stadt-zuerich.ch/dataset/luftqualitaet_historisierte-messungen/resource/7d069e56-86e9-44bf-9702-390a8e517564/download/ugzluftqualitaetsmessungseit2012.csv", .encoding = "UTF-8"))

# Ein Blick in die Daten zeigt uns, dass die komisch sind: 

head(luftqualität, 10)

# Das CSV hat mehrere Kopfzeilen (darunter Standort, was gemessen
# wird und die Einheit) bevor wir in der 6. Zeile zu den Messwerten
# kommen. So können wir damit noch nichts anfangen. Zur Übersicht
# entfernen wir erstmal die Spalten, die uns nicht interessieren
# (Das sind alle bis auf's Datum und die Lufttemperatur)

wetter <- luftqualität[, c("Datum", "X.Zürich.Stampfenbachstrasse.7")]
names(wetter) <- c("Datum", "Lufttemperatur °C")

# Jetzt parsen wir das Datum, entfernen die ersten 5 Zeilen und
# alle Daten, die nichts mit 2015 zu tun haben:

wetter$Datum <- as.POSIXct(wetter$Datum, "Europe/Zurich", "%d.%m.%Y")
wetter <- wetter[!is.na(wetter$Datum),]
wetter <- wetter[year(wetter$Datum) == 2015,] # year(…) ist aus dem package lubridate und gibt uns das Jahr als Zahl zurück

# Das plotten wir wieder:

ggplot(wetter, aes(Datum, `Lufttemperatur °C`)) + geom_line()

# Oh, das sieht komisch aus. Da wir vorher Text in den Spalten mit
# den Messwerten, müssen wir die Spalten (ähnlich wie beim Datum)
# noch als Zahlen parsen:

wetter$`Lufttemperatur °C` <- as.numeric(as.character(wetter$`Lufttemperatur °C`))
ggplot(wetter, aes(Datum, `Lufttemperatur °C`)) + geom_line()

# Auf den ersten Blick sieht das ja recht ähnlich aus, wie unsere
# Velozählungen, ein direkter Vergleich wäre natürlcih schöner. Mit
# dem Package grid können wir mehrere Graphen neben- und unter-
# einander zeichnen

if(!require(grid)) {
  install.packages("grid")
  require(grid)
}

# Um beide Graphen zu zeichnen müssen wir aus ihnen "Grid Graphical
# Objects" (grobs) machen. Diese weisen wir neuen Variablen zu und
# zeichnen sie mit dem Befehl grid.draw(…)

plot_velo <- ggplotGrob(ggplot(datum_gesamt, aes(Datum_Tag, Velo_total)) + geom_line())
plot_wetter <- ggplotGrob(ggplot(wetter, aes(Datum, `Lufttemperatur °C`)) + geom_line())

grid.draw(rbind(plot_velo, plot_wetter, size = "first"))

# Anfang April lässt sich der Zusammenhang zwischen der Anzahl
# Velos und der Temperatur besonders gut ausmachen. Kaum ist es
# für ein paar Tage hintereinander wieder kälter, sind weniger
# Velos auf den Strassen. Besonders viele Velos wurden an den 
# ersten Tagen mit über 20 Grad gemessen, der darauf gefolgte
# Temperatursturz auf unter 10 Grad macht sich ebenso bemerkbar.
#
# Möchten wir den Zusammenhang zwischen gezählten Velos und Tages-
# temperatur als zentrale Erkenntnis herausstellen, müssen wir uns
# noch Gedanken machen, wie wir das am besten darstellen.
#
# Wir haben am Anfang bereits geom_smooth(…) verwendet um uns einen
# besseren Überblick zu verschaffen. Mit dem Parameter span können
# wir bestimmen, wie smooth der Graph sein soll. Mit span = .1
# erhalten wir eine Linie, die genauer ist als ohne den Parameter,
# sich aber dennoch besser vergleichen lässt als die rohen Daten:

plot_velo <- ggplotGrob(ggplot(datum_gesamt, aes(Datum_Tag, Velo_total)) +
  geom_line(color="green") +
  geom_smooth(span = .1, se= FALSE, color = "red"))

plot_wetter <- ggplotGrob(ggplot(wetter, aes(Datum, `Lufttemperatur °C`)) +
  geom_line(color="green") +
  geom_smooth(span = .1, se= FALSE, color = "red"))

grid.draw(rbind(plot_velo, plot_wetter, size = "first"))

# Das macht es schon eingiges klarer, sieht dafür aber recht
# schrecklich aus. Neben den Farben der Linien (was zugegeben der
# Hauptgrund des schrecklichen Aussehens ist), lässt sich auch 
# alles  andere anpassen. ggplot2 hat dafür die Funktion theme(…).
# Details dazu gibt's hier: http://zevross.com/blog/2014/08/04/beautiful-plotting-in-r-a-ggplot2-cheatsheet-3/#working-with-the-background-colors
# und so sieht das beispielsweise aus:

t <- theme(plot.title = element_text(size=16, face="bold", colour = "#333333", margin = margin(10, 0, 10, 0), hjust = 0),
           panel.background = element_rect(fill = "#FFFFFF"),
           panel.grid.major = element_line(colour = "#EEEEEE", size = .5),
           panel.grid.minor = element_line(colour = "#EEEEEE", size = .5),
           plot.background = element_rect(fill = "#EEEEEE", colour = "#EEEEEE"),
           axis.ticks = element_line(colour = "#999999", size = .5),
           axis.text.x = element_text(colour = "#777777", margin = margin(5, 0, 3, 0)),
           axis.text.y = element_text(angle = 90, colour = "#777777", margin = margin(0, 5, 0, 3), hjust = 0.5),
           axis.title = element_text(colour = "#333333", face = "bold"),
           axis.title.y = element_text(angle = 90, margin = margin(0, 5, 0, 3), hjust = 0),
           axis.title.x = element_text(margin = margin(5, 0, 3, 0), hjust = 0),
           plot.margin = margin(0,10,5,5))

plot_velo <- ggplotGrob(ggplot(datum_gesamt, aes(Datum_Tag, Velo_total)) +
  geom_line(color="#DDDDDD") +
  geom_smooth(span = .1, se= FALSE, color = "#5182B3") +
  t) # Das vorher definierte theme wird hier angefügt

plot_wetter <- ggplotGrob(ggplot(wetter, aes(Datum, `Lufttemperatur °C`)) +
  geom_line(color="#DDDDDD") +
  geom_smooth(span = .1, se= FALSE, color = "#5182B3") +
  t)

grid.draw(rbind(plot_velo, plot_wetter, size = "first"))

# Wunderbar! Jetzt fehlt nur noch ein Titel, etwas bessere
# Achsenbeschriftungen und eigentlich brauchen wir nur eine 
# Beschriftung für die Monate.

plot_velo <- ggplotGrob(ggplot(datum_gesamt, aes(Datum_Tag, Velo_total)) +
  geom_line(color="#DDDDDD") +
  geom_point(size=.5, color = "#CC6788") + # Verdeutlicht die Varianzen
  geom_smooth(span = .1, se= FALSE, color = "#5182B3") +
  t +
  ggtitle("Veloaufkommen im Vergleich zur Tagestemperatur, Zürich 2015") + # Titel des Graphen
  xlab("") + ylab("Anzahl Velos") + # Achsenbeschriftungen
  theme(axis.ticks.x = element_blank(),axis.text.x = element_blank(), plot.margin = margin(0,10,-13,5)) + # Theme Anpassen um die X-Achsenbeschriftung beim ersten Graphen zuu entfernen
  scale_y_continuous(expand = c(0, 0), limits = c(0,55000), labels = function (x, ...) format(x, ..., big.mark = " ", scientific = FALSE, trim = TRUE)) + # Leerzeichen für bessere Lesbarkeit einfügen
  scale_x_datetime(date_breaks="1 month")) # Gleiches Grid, wie im zweitn Graphen zeichnen

plot_wetter <- ggplotGrob(ggplot(wetter, aes(Datum, `Lufttemperatur °C`)) +
  geom_line(color="#DDDDDD") +
  geom_point(size=.5, color = "#CC6788") +
  geom_smooth(span = .1, se= FALSE, color = "#5182B3") +
  t +
  scale_y_continuous(expand = c(0, 0), limits = c(-5,35)) +
  scale_x_datetime(labels=date_format("%b", tz= "Europe/Zurich"), date_breaks="1 month") + # Monats-Label ohne Jahr und für jeden Monat zeichnen
  xlab(""))

grid.draw(rbind(plot_velo, plot_wetter, size = "first"))

# Fertig!
# Weitere Infos zu R gibt's hier:
# http://journocode.com/
# http://zevross.com/blog/2014/08/04/beautiful-plotting-in-r-a-ggplot2-cheatsheet-3/
# http://srfdata.github.io/
# http://rddj.info/
# http://stackoverflow.com/questions/tagged/r