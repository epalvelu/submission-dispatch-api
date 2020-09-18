# Submission Dispatch API

*Submission Dispatch API* määrittelee rajapinnan sähköisen asiointipalvelun
kautta vastaanotettujen dokumenttien välittämiseen asiointipalvelusta
kohdejärjestelmään.

Rajapinta koostuu REST-palvelusta, jonka toteuttaa dokumentteja vastaanottava
taho. Asiointipalvelu toimii rajapinnan asiakkaana. Rajapinnan toiminnot ja
tietorakenteet kuvataan OpenAPI 3.0 -määrittelyssä `submission-dispatch.yaml`.
Tässä dokumentissa tarkennetaan rajapinnan käyttöön ja tietoturvaan liittyviä
asioita.

- [Sanasto](#sanasto)
- [Yleiskuvaus](#yleiskuvaus)
- [Tietoturva](#tietoturva)
- [Rajapinnan testaaminen](#rajapinnan-testaaminen)
- [Asiointitapahtuman toimitus](#asiointitapahtuman-toimitus)
- [Asiointitapahtuman toimituksen tila](#asiointitapahtuman-toimituksen-tila)
- [Tietorakenteet](#tietorakenteet)


## Sanasto

*Asiointitapahtuma* (engl. *submission*) – sähköisen asiointipalvelun
käyttötapahtuma, jossa syntyy sähköinen asiakirja eli dokumentti.
Asiointitapahtuma voi olla esimerkiksi hakemus tai ilmoitus.
Asiointitapahtumalla on yksikäsitteinen tunnus (*submission key*).

*Dokumentti* (engl. *document*) – sähköisen asiointipalvelun käytöstä syntyvä
sähköinen asiakirja. Dokumentin tunnus kertoo, mistä asiakirjasta on kyse.

*Asiointitapahtuman sisältö* (engl. *submission content*) – tiedosto tai
tiedostot, jotka syntyvät tai saadaan asiointitapahtumassa. Asiointitapahtuman
sisältönä on vähintään varsinainen sähköinen asiakirja, joka on yleensä
PDF-tiedosto. Muita sisltöjä ovat koneluettava asiakirja sekä liitetiedostot.

*Asiointipalvelu* (engl. *e-business service*) – palvelu, jossa loppukäyttäjä
asioi ja asiointitapahtuma syntyy. Asiointipalvelu toimii tämän rajapinnan
asiakkaana ja lähettää asiointitapahtumien tiedot toimituspalveluun.

*Toimituspalvelu* (engl. *dispatch service*) – palvelu, joka toteuttaa
tämän rajapinnan vastaanottaakseen asiointitapahtumien tietoja ja
tallentaakseen ne kohdejärjestelmään.

*Kohdejärjestelmä* (engl. *target system*) – järjestelmä, johon toimituspalvelu
tallentaa tai välittää asiointitapahtumien tiedot. Kohdejärjestelmä voi
olla esimerkiksi tiedostojärjestelmä tai dokumentinhallintajärjestelmä.

*Todennus* (engl. *authentication*) – Asiointipalvelussa suoritettu todennus,
jossa varmistetaan asiointitapahtuman tekijän henkilöllisyys. Todennuksessa
saadut tiedot sisältyvät asiointitapahtuman tietoihin.

*Valtuutus* (engl. *authorization*) – Asiointipalvelussa suoritettu valtuutus,
jossa varmistetaan asiointipalvelun käyttäjän oikeus toimia toisen henkilön
tai organisaation puolesta. Valtuutuksessa saadut tiedot sisältyvät
asiointitapahtuman tietoihin.


## Yleiskuvaus

Rajapinta toimii kahden eri organisaation, asiointipalvelun tuottajan
sekä asiointitapahtumien vastaanottajan, välisenä tietojärjestelmien
integraatiorajapintana.

Asiointipalvelu välittää asiointitapahtumien tiedot yhdelle tai useammalle
vastaanottajalle. Kukin vastaanottaja ylläpitää toimituspalvelua omassa
järjestelmäympäristössään.

Vastaanottajalla on järjestelmäympäristössään toimituspalvelun lisäksi yksi
tai useampia kohdejärjestelmiä, joihin asiointitapahtumien tiedot
tallennetaan. Asiointipalvelusta saapuva tietoliikenne sisäverkkoon ohjautuu
keskitetysti toimituspalvelun rajapinnan kautta, mikä helpottaa
verkkoyhteyksien ja tietoturvan järjestämistä ja tietoliikenteen seurantaa.

Toimituspalvelu välittää vastaanotetut dokumentit oikeaan kohdejärjestelmään.
Asiointipalvelu voi määritellä toimitustiedoissa kohdejärjestelmän tunnuksen
ja tarkemman kohdepolun. Tämä mahdollistaa sen, että eri dokumenttien tarkat
kohteet määritellään asiointipalvelun asetuksissa, eikä toimituspalvelussa
tarvitse välttämättä käsitellä dokumenttien sisältöjä kohteen
määrittelemiseksi.

Esimerkiksi asiointipalvelun asetuksissa voidaan määritellä, että
venepaikkahakemukset toimitetaan kohteeseen `hakemukset` ja kohdepolkuun
`/yhdyskuntapalvelut/venepaikkahakemukset`.

Toimituspalvelun asetuksissa puolestaan voidaan määritellä, että kohde
`hakemukset` on tiedostopalvelimen jaettu hakemisto `\\LOI01\Hakemukset`.
Tällöin venepaikkahakemukset tallennetaan tiedostopalvelimelle
hakemistoon `\\LOI01\Hakemukset\yhdyskuntapalvelut\venepaikkahakemukset`.

Toimituspalvelu voi julkaista palvelun toiminnot missä tahansa sopivassa
palvelinosoitteessa, portissa ja alipolussa, esimerkiksi
`https://myendpoint.mydomain:8443/api/submission-dispatch/`.


## Tietoturva

Tietoliikenne asiointipalvelun ja toimituspalvelun välillä käytetään
kaksisuuntaista TLS-autentikointia. Lisäksi pyyntöihin sisältyy API-avain
`API Key`-otsakkeessa.

Asiointipalvelun tulee varmistaa yhteyttä muodostettaessa, että vastapuolen
palvelinvarmenne tai julkinen avain on oikea, ennalta sovittu varmenne tai
avain. Tämä varmistaa, että arkaluonteisia tietoja ei missään tapauksessa
lähetetä tuntemattomalle osapuolelle (esim. man-in-the-middle-hyökkäys).

Toimituspalvelun tulee varmistaa, että vastapuolen asiakasvarmenne tai sen
julkinen avain on oikea, ennalta sovittu varmenne tai avain. Lisäksi
toimituspalvelun tulee tarkistaa, että pyynnön `API-Key`-otsakkeessa annettu
API-avain on oikea. Mikäli asiakasvarmenteen tarkistus on hankala toteuttaa
ympäristökohtaisista syistä, on mahdollista rajata palveluun pääsy palomuurilla
ja tarkistaa pelkästään API-avain.

Toimituspalvelun palvelinsertifikaatti ja asiointipalvelun asiakassertifikaatti
voivat olla itse allekirjoitettuja, lähettäjä- tai vastaanottajaorganisaation
myöntämiä tai ulkopuolisen varmenteiden myöntäjän myöntämiä.

API-avain luodaan palvelun käyttöönoton yhteydessä. Jos toimituspalvelu ottaa
vastaan tietoja useammasta eri asiointipalvelusta, on näillä oltava eri
API-avaimet.

Sertifikaattien ja API-avaimen käyttöönotto- ja uusimismenettelyjä ei
määritellä tarkemmin tässä rajapintakuvauksessa.


## Rajapinnan testaaminen

Rajapinnan toteutusta voi testata esimerkiksi `curl`-komennolla.

### Asiointitapahtuman toimitus

```shell
curl \
  --cacert server.crt \
  --cert client.crt \
  --key client.key \
  --pass passwordForClientKey \
  -H "API-Key: d082af99-0576-4dae-8ef0-35ad32e937d4" \
  -F "message=@sample-message.json;type=application/json" \
  -F "files=@sample-document.pdf" \
  -F "files=@sample-attachment.png" \
  https://myendpoint.mydomain:8443/api/submission-dispatch/submissions
```

Komennossa annetaan seuraavat tiedot:
- Palvelimen sertifikaatti tiedostossa `server.crt`. Sertifikaatti on
  annettava optiolla `--cacert`, jos palvelin käyttää itseallekirjoitettua
  sertifikaattia tai jos halutaan tarkistaa, että sertifikaatti on oikea;
  muussa tapauksessa option voi jättää pois.
- Asiakkaan sertifikaatti ja yksityinen avain tiedostoissa `client.crt` ja
  `client.key`. Nämä sekä mahdollinen avaimen salasana on annettava
  optioilla `--cert`, `--key` ja `--pass`, jos kaksisuuntainen
  TLS-autentikointi on käytössä; muussa tapauksessa optiot voi jättää pois.
- API-avain HTTP-otsakkeessa `API-Key`.
- Pyynnön viestiosa tiedostossa `sample-message.json`. Viestiosa on
  [`SubmissionDispatch`]-skeematyypin mukainen JSON-rakenne, ks. esimerkki
  alempana.
- Asiointitapahtuman sisällöt tiedostoissa `sample-document.pdf` ja
  `sample-attachment.png`. Tiedostojen lukumäärän ja tiedostonimien pitää
  vastata viestiosassa esiteltyjä sisältöjä ([`SubmissionContent`]).
- Palveluresurssin URL-osoite.

Jos asiakkaan sertifikaatti ja yksityinen avain ovat PKCS#12-muodossa,
korvaa optiot `--cert`, `--key` ja `--pass` seuraavilla:
```shell
  --cert client.p12 \
  --cert-type p12 \
  --pass passwordForClientKey \
```

Tuotantokäytössä olevaa järjestelmää testatessa kannattaa viestiosaan asettaa
ominaisuus `"test": true`, jotta testit voidaan erottaa varsinaisista
asiointitapahtumista.


### Asiointitapahtuman toimituksen tilakysely

```shell
curl \
  --cacert server.crt \
  --cert client.crt \
  --key client.key \
  --pass passwordForClientKey \
  -H "API-Key: d082af99-0576-4dae-8ef0-35ad32e937d4" \
  https://myendpoint.mydomain:8443/api/submission-dispatch/submissions/a37fea75-a2a8-4898-ab70-bf0e8b6f5c3b
```

Komennossa annetaan seuraavat tiedot:
- Palvelimen ja asiakkaan sertifikaatit sekä API-avain kuten edellä.
- Palveluresurssin URL-osoite, jonka viimeinen osa on asiointitapahtuman tunnus.
  Asiointitapahtuman tunnus annetaan toimituspyynnön viestiosan
  `submissionKey`-kentässä.


## Asiointitapahtuman toimitus

`POST /submissions` tallentaa tai välittää asiointitapahtuman tiedot
kohdejärjestelmään. Pyynnön sisältönä on asiointitapahtuman metatiedot ja
sisällöt. Vastaus sisältää käsittelyn tilan.


### Pyyntö

Pyynnön mediatyyppi on `multipart/form-data` ja koostuu seuraavista osista:

- `message` – Viestiosa, sisältää asiointitapahtuman toimituksen metatiedot.
   Viestiosan skeematyyppi on [`SubmissionDispatch`] ja mediatyyppi
   `application/json`.
- `files` – Tiedosto. Tiedostoja voi olla yksi tai useampi. Tiedostonimi on
  annettava `Content-Disposition`-otsakkeen `filename`-parametrissa.
  Tiedostonimien on oltava yksikäsitteisiä ja niiden tulee vastata
  asiointitapahtuman metatiedoissa määriteltyjä tiedostonimiä. Tiedosto-osan
  mediatyyppiä ei huomioida.

```http
POST /api/submission-dispatch/submissions HTTP/1.1
Host: myendpoint.mydomain:8443
API-Key: d082af99-0576-4dae-8ef0-35ad32e937d4
Content-Type: multipart/form-data; boundary=----Omz20xyMCkE27rN7ds8834jnk3r

------Omz20xyMCkE27rN7ds8834jnk3r
Content-Disposition: form-data; name="message"
Content-Type: application/json

{
  "targetId": "hakemukset",
  "targetPath": "/yhdyskuntapalvelut/venepaikkahakemukset",
  "test": true,
  "submission": {
    "submissionKey": "a37fea75-a2a8-4898-ab70-bf0e8b6f5c3b",
    "submissionTime": "2020-04-14T11:05:12Z",
    "organization": {
      "id": "Loimusaari",
      "name": "Loimusaaren kaupunki",
      "oid": "1.2.246.10.8429083"
    },
    "unit": {
      "id": "LoimusaariYhdPal",
      "name": "Yhdyskuntapalvelut",
      "oid": "1.2.246.10.8429083.17"
    },
    "document": {
      "id": "2140002",
      "version": "2",
      "language": "fi",
      "name": "Venepaikkahakemus",
      "oid": "1.2.246.10.8429083.322.54"
    },
    "authentication": {
      "transactionId": "aSX29dT89LDas23bcx9kj2423mMZ33",
      "transactionTime": "2020-04-14T11:02:22Z",
      "properties": {
        "menetelmä": "suomi.fi"
      }
    },
    "authorizations": [
      {
        "transactionId": "FD0el43lgdf8SJ98212iUxwfFFweRp",
        "transactionTime": "2020-04-14T11:03:37Z",
        "properties": {
          "menetelmä": "suomi.fi",
          "tyyppi": "YrityksenPuolesta"
        }
      }
    ],
    "properties": {
      "hakija": "Louhisaaren Venekerho ry",
      "kohde": "Kivikkoranta"
    },
    "contents": [
      {
        "fileName": "sample-document.pdf",
        "fileType": "Document",
        "mediaType": "application/pdf"
      },
      {
        "fileName": "sample-attachment.png",
        "fileType": "Attachment",
        "mediaType": "image/png",
        "attachmentId": "Kuva"
      }
    ]
  }
}
------Omz20xyMCkE27rN7ds8834jnk3r
Content-Disposition: form-data; name="files"; filename="sample-document.pdf"

%PDF-1.7
...
%%EOF
------Omz20xyMCkE27rN7ds8834jnk3r
Content-Disposition: form-data; name="files"; filename="sample-attachment.png"

ÿØÿà...
------Omz20xyMCkE27rN7ds8834jnk3r--
```


### Vastaus

Toimituspalvelu palauttaa vastauksen heti, kun pyyntö on kokonaan otettu
vastaan. Vastauksen skeematyyppi on [`SubmissionDispatchState`] ja mediatyyppi
`application/json`. Vastauskoodit:
- `200 OK` – tiedot tallennettiin saadaan välittömästi kohdejärjestelmään.
  Vastausviestissä toimituksen tila on `Success`.
- `202 Accepted` – tietojen tallennus kohdejärjestelmään on kesken. Tämä
  vastaus palautetaan, jos tietojen tallennus kohdejärjestelmään kestää
  kauemmin. Vastausviestissä toimituksen tila on `InProgress`. Kesken olevan
  tallennuksen tilaa voi seurata [`GET /submissions/{submissionKey}`]
  -pyynnöllä.

```http
HTTP/1.1 200 OK
Date: Tue, 14 Apr 2020 11:07:23 GMT
Content-Type: application/json

{
  "submissionKey": "a37fea75-a2a8-4898-ab70-bf0e8b6f5c3b",
  "dispatchTime": "2020-04-14T11:07:23Z",
  "dispatchStatus": "Success"
}
```


### Virheet

Jos pyynnön käsittelyssä tapahtuu virhe, toimituspalvelu palauttaa
HTTP-virhekoodin `4xx` (asiakkaan virheet) tai `5xx` (palvelimen virheet).
Virhevastauksen skeematyyppi on [`Error`] ja mediatyyppi `application/json`.
Virhekoodit:
- `400 Bad Request` – pyyntö ei ole oikean muotoinen, esimerkiksi viestiosan
  JSON-rakenne on vääränlainen, pakollisia kenttiä puuttuu, viestissä on
  tuntemattomia kenttiä, tai tiedosto-osien lukumäärä tai tiedostonimet eivät
  vastaa viestiosan tietoja
- `401 Unauthorized` – vaadittu autentikointitieto puuttuu tai ei salli
  tämän toiminnon käyttöä
- `403 Forbidden` – asiointitapahtuman tietojen tallennus epäonnistui, koska
  toimituksen kohde tai kohteen polku ei ole sallittu
- `409 Conflict` – asiointitapahtuman tietojen tallennus epäonnistui, koska
  tiedot on tallennettu jo aiemmin eikä niiden päivitys onnistu
- `500 Internal Server Error` – asiointitapahtuman tallennuksessa tapahtui
  virhe toimituspalvelussa tai kohdejärjestelmässä.

```http
HTTP/1.1 400 Bad Request
Date: Tue, 14 Apr 2020 11:07:23 GMT
Content-Type: application/json

{
  "status": 400,
  "title": "Bad Request",
  "detail": "Field 'message' is missing."
}
```


## Asiointitapahtuman toimituksen tila

`GET /submissions/{submissionKey}` palauttaa asiointitapahtuman toimituksen
tilan.

Toiminnon tarkoitus on, että asiointipalvelu voi tunnistaa asynkronisessa
toimituksessa ([`POST /submissions`] palauttaa `202 Accepted`) tapahtuvan
virheen ja käynnistää toimituksen tarvittaessa uudelleen.

Synkronisten ja epäonnistuneiden toimitusten ([`POST /submissions`] palauttaa
`200 OK`, `4xx` tai `5xx`) tilan ei tarvitse olla kysyttävissä; vastaus voi
aina olla virhe `404 Not Found`.

Asynkronisten toimitusten osalta riittää, että tila on kysyttävissä toimituksen
keston ajan sekä sopivan ajan toimituksen valmistuttua, esimerkiksi tunnin.
Toimituspalvelun ei tarvitse tallentaa tilatietoa pysyvästi.

Jos toimituspalvelu ei käytä asynkronista toimitusta, niin tätä palvelua ei
tarvitse toteuttaa lainkaan, vaan vastaus voi aina olla virhe `404 Not Found`.
Jos asiointipalvelu saa tilakyselyyn vastauksen `404 Not Found`, se voi
olettaa, että toimitus on onnistunut.


### Pyyntö

Pyynnön polkuparametri `{submissionKey}` on asiointitapahtuman tunnus. Pyynnön
sisältö on tyhjä.

```http
GET /api/submission-dispatch/submissions/a37fea75-a2a8-4898-ab70-bf0e8b6f5c3b HTTP/1.1
Host: myendpoint.mydomain:8443
API-Key: d082af99-0576-4dae-8ef0-35ad32e937d4
```


### Vastaus

Vastauksen skeematyyppi on [`SubmissionDispatchState`] ja mediatyyppi
`application/json`. Vastauskoodit:
- `200 OK` – toimitus on kesken tai valmistunut äskettäin. Vastauksessa
  toimituksen tila on `InProgress`, `Success` tai `Failure`.

```http
HTTP/1.1 200 OK
Date: Tue, 14 Apr 2020 11:07:23 GMT
Content-Type: application/json

{
  "submissionKey": "a37fea75-a2a8-4898-ab70-bf0e8b6f5c3b",
  "dispatchTime": "2020-04-14T11:07:23Z",
  "dispatchStatus": "InProgress"
}
```


### Virheet

Virhetilanteissa tilakysely palauttaa HTTP-virhekoodin `4xx` (asiakkaan
virheet) tai `5xx` (palvelimen virheet). Virhevastauksen skeematyyppi on
[`Error`] ja mediatyyppi `application/json`. Virhekoodit:
- `404 Not Found` – toimituksen tila ei ole saatavilla. Syy voi olla jokin
   seuraavista:
   - toimitus tapahtui synkronisesti (`POST /submissions` -pyyntö palautti
     `200 OK`)
   - toimituspyynnössä tapahtui virhe (`POST /submissions` -pyyntö palautti
     virhevastauksen)
   - toimitus valmistui ja tilatieto ei ole enää saatavilla
   - asiointitunnus `{submissionKey}` on väärä
   - tilakyselyä ei ole toteutettu
- `401 Unauthorized` – vaadittu autentikointitieto puuttuu tai ei salli
  tämän toiminnon käyttöä
- `500 Internal Server Error` – pyynnön käsittelyssä tapahtui virhe.

```http
HTTP/1.1 404 Not Found
Date: Tue, 14 Apr 2020 11:07:23 GMT
Content-Type: application/json

{
  "status": 404,
  "title": "Not Found"
}
```

## Tietorakenteet

Tietorakenteiden ominaisuudet ovat pakollisia ja tekstimuotoisia, ellei muuta
ole mainittu. Aikaleimat esitetään tekstimuodossa RFC 3339 -määrittelyn
mukaisesti.


### `SubmissionDispatch`

Toimitettavan asiointitapahtuman tiedot. Ominaisuudet:
- `targetId` – Kohdejärjestelmän tunnus. Tunnus voi olla tyhjä.
- `targetPath` – Polku kohdejärjestelmässä, johon tiedot tallennetaan. Polku
  voi olla tyhjä.
- `test` (totuusarvo, valinnainen) – Jos arvo on `true`, asiointitapahtuma on
  testi. Toimituspalvelu varmistaa, että tietojen toimitus kohdejärjestelmään
  toimii ja sitten hävittää asiointitapahtuman tiedot. Jos arvo on `false` tai
  puuttuu, toimituspalvelu käsittelee asiointitapahtuman normaalisti.
- `submission` ([`Submission`]-objekti) – Asiointitapahtuman metatiedot.


### `Submission`

Asiointitapahtuman metatiedot. Ominaisuudet:
- `submissionKey` – Asiointitapahtuman yksikäsitteinen tunnus, esimerkiksi
  UUID.
- `submissionTime` (aikaleima) – Asiointitapahtuman hetki.
- `organization` (objekti) – Asiointitapahtuman omistavan organisaation
  tunnisteet:
  - `id` – Organisaation tunnus asiointipalvelussa.
  - `name` (valinnainen) – Organisaation nimi.
  - `oid` (valinnainen) – Organisaation OID-tunnus ISO/IEC 8824-1 -standardin
    mukaan.
- `unit` (objekti) – Asiointitapahtuman omistavan organisaatioyksikön
  tunnisteet:
  - `id` – Yksikön tunnus asiointipalvelussa.
  - `name` (valinnainen) – Yksikön nimi.
  - `oid` (valinnainen) – Yksikön OID-tunnus ISO/IEC 8824-1 -standardin mukaan.
- `document` (objekti) – Asiointitapahtumassa syntyneen dokumentin tunnisteet:
  - `id` – Dokumentin tunnus asiointipalvelussa.
  - `version` – Dokumentin versiotunnus.
  - `language` – Dokumentin kielikoodi ISO 639-1 -standardin mukaan.
  - `name` (valinnainen) – Dokumentin nimi.
  - `oid` (valinnainen) – Dokumentin OID-tunnus ISO/IEC 8824-1 -standardin
   mukaan.
- `authentication` (objekti, valinnainen) – Tieto asiointitapahtuman tekijän
  henkilöllisyyden todennuksesta. Tieto puuttuu, jos todennusta ei tehty.
  Todennustiedon ominaisuudet:
  - `transactionId` – Todennustapahtuman tunnus.
  - `transationTime` (aikaleima) – Todennustapahtuman aikaleima.
  - `properties` (objekti) – Todennustapahtuman lisäominaisuudet. Objekti voi
    sisältää mitä tahansa ominaisuuksia, riippuen siitä miten todennus on
    tehty. Ominaisuuksien arvot ovat tekstityyppisiä.
- `authorizations` (lista objekteja, valinnainen) – Tieto asiointitapahtuman
  yhteydessä tehdyistä valtuutuksista. Tieto puuttuu, jos valtuutusta ei tehty.
  Valtuutustiedon ominaisuudet:
  - `transactionId` – Todennustapahtuman tunnus.
  - `transationTime` (aikaleima) – Todennustapahtuman aikaleima.
  - `properties` (objekti) – Todennustapahtuman lisäominaisuudet. Objektissa
    voi olla mitä tahansa ominaisuuksia, arvot ovat tekstityyppisiä.
- `properties` (objekti, valinnainen) – Asiointitapahtuman lisäominaisuudet,
  esimerkiksi asiointitapahtuman sisällöstä poimittuja tietoja. Objektissa voi
  olla mitä tahansa ominaisuuksia, arvot ovat tekstityyppisiä.
- `contents` (lista [`SubmissionContent`]-objekteja) – Asiointitapahtuman
  sisältöjen tiedot. Sisältöjä on oltava vähintään yksi.


### `SubmissionContent`

Asiointitapahtuman sisällön tiedot. Sisältöjen tiedostonimien (`fileName`)
täytyy olla yksikäsitteisiä asiointitapahtuman sisällä ja niiden täytyy vastata
toimituspyynnössä välitettyjen tiedostojen tiedostonimiä
(`Content-Disposition`-otsakkeen `filename`). Ominaisuudet:
- `fileName` – Tiedostonimi.
- `fileType` – Tiedoston tyyppi, yksi seuraavista arvoista:
  - `"Document"` – Varsinainen sähköinen asiakirja.
  - `"DocumentData"` – Asiakirjan tietosisältö koneluettavassa muodossa.
  - `"Attachment"` – Asiakirjan liite.
- `mediaType` (valinnainen) – Mediatyyppi, esimerkiksi `application/pdf`.
- `attachmentId` (valinnainen) – Liitteen tunnus. Liitteen tunnuksen avulla
  voidaan erottaa asiointitapahtumaan liittyvät liitteet toisistaan.


### `SubmissionDispatchState`

Asiointitapahtuman toimituksen tila. Ominaisuudet:
- `submissionKey` – Asiointitapahtuman tunnus.
- `dispatchTime` (aikaleima) – Toimituksen aloitushetki.
- `dispatchStatus` – Toimituksen tilakoodi, yksi seuraavista arvoista:
  - `"Success"` – toimitus onnistui
  - `"InProgress"` – toimitus on kesken
  - `"Failure"` – toimitus epäonnistui


### `Error`

Virhevastauksen sisältö. Ominaisuudet:
- `status` (numero välillä 100..599) – HTTP-tilakoodi.
- `title` – Virheen otsikko.
- `detail` (valinnainen) – Virheen tarkempi kuvaus.


[`POST /submissions`]: #asiointitapahtuman-toimitus
[`GET /submissions/{submissionKey}`]: #asiointitapahtuman-toimituksen-tila
[`SubmissionDispatch`]: #submissiondispatch
[`Submission`]: #submission
[`SubmissionContent`]: #submissioncontent
[`SubmissionDispatchState`]: #submissiondispatchstate
[`Error`]: #error
