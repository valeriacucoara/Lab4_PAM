# Laboratorul 4 – GemStore (Flutter, REST API, JSON, Clean Architecture)

**Acest folder este un proiect Flutter COMPLET, independent de Lab3.** A fost creat pornind de la arhiva originală `lab3.rar`, fără a modifica fișierele acelui laborator. Pe Android, această aplicație se instalează sub identificatorul **`com.example.gemstorelab4`** și numele **Lab4**; Lab3 rămâne `com.example.lab3`.

## 1. Ce păstrăm din Lab3

- Stilul vizual GemStore: header, categorii, banner Autumn Collection, produse în carusel, secțiuni New Collection / Recommended / Top Collection / category promos.
- Pagina produsului (imagine, favorite, titlu/preț, culori, mărimi, descriere, recenzii, produse similare și buton Add To Cart).
- Căutarea după nume, filtrarea după preț, sortarea și favoritele gestionate prin Cubit.
- Imaginile originale din `assets/images/` ca elemente vizuale și fallback la eroare de încărcare a imaginilor online. **Niciun produs nu este încărcat din JSON local.**
- Coș demo local, cu vizualizarea produselor, cantităților și totalului, ca funcționalitate suplimentară. Nu trimite comenzi pe server.

Fotografiile de pe bannere și carduri **pot arăta diferit** de Lab3: acum vin din URL-urile furnizate de server. Structura secțiunilor și funcționalitățile rămân.

## 2. API-urile folosite

- `GET https://test-api-jlbn.onrender.com/lab2026/v1/feed` — titlul magazinului, categoriile, bannerul, `featureProducts`, `recommended`, `newCollection`, `topCollections`, `categoryPromos`.
- `GET https://test-api-jlbn.onrender.com/lab2026/v1/feed/details` — **un singur produs**: `p003` (Sportwear Set), cu `mainImageUrl`, `availableColors`, `availableSizes`, `sizeAvailability`, descriere, rating, ratingBreakdown, reviews, similarProducts și actions.

**Atenție:** API-ul NU oferă detalii pentru `p001`, `p002`, `p004` etc. În cazul lor pagina își păstrează secțiunile, dar nu inventează ratinguri, culori sau recenzii. Pentru `p003`, valorile complete sunt primite online. De asemenea, API-ul primit conține doar endpointuri de citire GET; coșul este intenționat local, nu este un serviciu `POST` inventat.

Dacă endpointul de detalii nu funcționează, pagina principală continuă să arate produsele din `/feed`. Pe pagina `p003` poți folosi Retry. Dacă `/feed` nu funcționează, interfața afișează eroare și buton Retry.

## 3. Clean Architecture

```text
lib/
├── main.dart                              # injectarea dependențelor
├── domain/
│   ├── entities/
│   │   ├── product.dart                  # Product, ProductColor, ProductReview
│   │   └── store_feed.dart               # StoreFeed, bannere, categorii
│   └── repositories/store_repository.dart # contract abstract
├── data/
│   ├── datasources/store_api_service.dart # GET HTTP + JSON + timeout + erori
│   ├── models/store_dto.dart              # conversia JSON -> entități Dart
│   └── repositories/store_repository_impl.dart # implementarea contractului
└── presentation/
    ├── cubit/
    │   ├── store_cubit.dart              # Loading/Success/Empty/Error + filtre
    │   ├── store_state.dart
    │   ├── product_detail_cubit.dart     # încărcarea asincronă a lui p003
    │   └── cart_cubit.dart               # coș de demonstrație local
    ├── screens/
    │   ├── home_page.dart
    │   ├── product_page.dart
    │   └── cart_page.dart
    └── widgets/
        ├── product_card.dart
        └── store_sections.dart           # imagini și bannere reutilizabile
```

### Fluxul de date (cum explici profesoarei)

1. `main.dart` creează `http.Client`, `StoreApiService`, `StoreRepositoryImpl` și `StoreCubit` prin `RepositoryProvider`/`BlocProvider`.
2. `HomePage` afișează `StoreLoading` și cere `StoreCubit.loadProducts()`.
3. Cubit-ul apelează metoda **abstractă** `StoreRepository.fetchFeed()`.
4. Implementarea din Data execută `http.Client.get(Uri.parse(.../feed))` și primește JSON.
5. `StoreFeedDto.fromJson` deserializază JSON-ul în obiecte Dart din Domain.
6. Cubit emite `StoreSuccess`; UI construiește cardurile cu `Image.network` și textele primite din API. Search/filter/sort/favorite se aplică local peste datele descărcate.
7. Endpointul `/feed/details` completează `p003` și produsele similare. La deschiderea paginii `p003`, `ProductDetailCubit` solicită din nou datele actualizate; loading/error/success sunt gestionate separat.

**Serializare vs. deserializare**: `jsonDecode` realizează deserializarea JSON -> date Dart. În testele API se verifică și că răspunsurile HTTP sunt tratate corect. Endpoints-urile oferite nu expun un `POST` de salvare, deci proiectul nu inventează trimiterea pe server a coșului de cumpărături.

## 4. Cum deschizi și rulezi pe telefonul Android

1. **Nu copia acest proiect peste `Lab3\lab3`.** Extrage arhiva completă într-un folder NOU, de exemplu `D:\Bogdana\Universitati\UTM\Anul4\PAM\Laburi\Lab4_FINAL\Lab4_GemStore`.
2. În Android Studio: **File → Open** → selectează folderul în care există `pubspec.yaml` și `android`.
3. Asigură-te că Flutter SDK path indică spre Flutter-ul tău instalat:
   `D:\Bogdana\Universitati\UTM\Anul4\PAM\Flutter\sdk\flutter`
4. Dacă PowerShell nu recunoaște `flutter`, într-un terminal nou execută:

   ```powershell
   $env:Path = 'D:\Bogdana\Universitati\UTM\Anul4\PAM\Flutter\sdk\flutter\bin;' + $env:Path
   ```

5. În directorul noului proiect:

   ```powershell
   flutter pub get
   flutter analyze
   flutter test
   flutter devices
   flutter run
   ```

6. Dacă se afișează o listă de dispozitive, selectează numărul telefonului, nu Windows/Chrome. Sau rulează `flutter run -d ID_TELEFON` cu ID-ul din `flutter devices`.

Așteptat: pe telefon există **două aplicații independente**, „lab3” și **„Lab4”**.

## 5. Checklist de verificare

- [ ] Telefonul arată iconița **Lab4** și iconița veche **lab3** (sunt aplicații distincte).
- [ ] Home încarcă online storeName, categorii, Autumn Collection, Feature Products, Recommended, Top Collection, promoții.
- [ ] Produsele au preț și imagine din `GET /feed`.
- [ ] Search „Dress” găsește `p002`; filtrul Under $40 și sortarea funcționează.
- [ ] Inima de Favorite se schimbă la atingere.
- [ ] Sportwear Set (`p003`) încarcă din `GET /feed/details` descrierea, culorile, mărimile, recenziile și cele 3 produse similare.
- [ ] Pe celelalte produse nu apare eroarea falsă „/feed/details nu conține detalii pentru p002”.
- [ ] Add To Cart poate fi apăsat, iar My Cart arată produsul, cantitatea și totalul.
- [ ] Cu internetul oprit, apare gestionarea erorii și Retry; cu internetul pornit, reîncărcarea funcționează.

## 6. Teste automate

`flutter test` conține teste cu `MockClient` pentru ambele adrese GET, maparea câmpurilor JSON, funcționalitățile din Lab3, tratarea HTTP 503/JSON invalid și afișarea coșului gol. Acestea nu depind de disponibilitatea serverului real.

> **Stadiul verificării:** Proiectul a fost verificat structural și sursele API au fost inspectate, dar nu a putut fi rulat `flutter analyze`, `flutter test` sau compilarea APK în mediul de generare (Flutter SDK nu este disponibil aici). Te rog să rulezi comenzile de la punctul 4 pe calculator înainte de predare și să trimiți orice eroare exactă, dacă apare.
